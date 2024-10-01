//
//  VirtualMachineView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/24/24.
//

import SwiftUI
import Virtualization

fileprivate let pixelsPerInch = 284

struct VirtualMachineView: NSViewRepresentable {
    typealias NSViewType = VZVirtualMachineView
    
    let size: CGSize
    
    func makeNSView(context: Context) -> NSViewType {
        let virtualMachine = context.coordinator.virtualMachine
        let view = VZVirtualMachineView(frame: .zero)
        view.virtualMachine = virtualMachine
        context.coordinator.restoreVirtualMachine()
        return view
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        self.refreshDisplaySize(coordinator: context.coordinator)
    }
    
    private func refreshDisplaySize(coordinator: Coordinator) {
        if coordinator.previousSize != size {
            coordinator.updateDisplaySize(width: Int(size.width), height: Int(size.height))
        }
        
        coordinator.previousSize = size
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(virtualMachine: VZVirtualMachine(configuration: VirtualMachineConfiguration(widthInPixels: Int(size.width), heightInPixels: Int(size.height)).createVirtualMachine()), size: size)
    }
    
    class Coordinator: NSObject, VZVirtualMachineDelegate {
        let virtualMachine: VZVirtualMachine
        
        let size: CGSize
        var previousSize: CGSize? = nil
        
        init(virtualMachine: VZVirtualMachine, size: CGSize) {
            self.virtualMachine = virtualMachine
            self.size = size
            self.previousSize = size
            print(size)
            super.init()
                
            self.virtualMachine.delegate = self
        }
        
        func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
            print(error)
        }
        
        func startVirtualMachine() {
            virtualMachine.start(completionHandler: { (result) in
                if case let .failure(error) = result {
                    fatalError("Virtual machine failed to start with \(error)")
                }
            })
        }

        func resumeVirtualMachine() {
            virtualMachine.resume(completionHandler: { (result) in
                if case let .failure(error) = result {
                    fatalError("Virtual machine failed to resume with \(error)")
                }
            })
        }
        
        func restoreVirtualMachine() {
            virtualMachine.restoreMachineStateFrom(url: VirtualMachineConfiguration(widthInPixels: Int(size.width), heightInPixels: Int(size.height)).saveFileURL, completionHandler: { (error) in
                let fileManager = FileManager.default
//                try! fileManager.removeItem(at: VirtualMachineConfiguration().saveFileURL)

                if error == nil {
                    self.resumeVirtualMachine()
                } else {
                    self.startVirtualMachine()
                }
            })
        }

        func saveVirtualMachine(completionHandler: @escaping () -> Void) {
            virtualMachine.saveMachineStateTo(url: VirtualMachineConfiguration(widthInPixels: Int(size.width), heightInPixels: Int(size.height)).saveFileURL, completionHandler: { (error) in
                guard error == nil else {
                    fatalError("Virtual machine failed to save with \(error!)")
                }
                completionHandler()
            })
        }

        func pauseAndSaveVirtualMachine(completionHandler: @escaping () -> Void) {
            virtualMachine.pause(completionHandler: { (result) in
                if case let .failure(error) = result {
                    fatalError("Virtual machine failed to pause with \(error)")
                }
                self.saveVirtualMachine(completionHandler: completionHandler)
            })
        }
        
        func updateDisplaySize(width: Int, height: Int) {
            if let graphicsDevice = virtualMachine.graphicsDevices.first,
            let graphicsDisplay = graphicsDevice.displays.first {
                do {
                    try graphicsDisplay.reconfigure(sizeInPixels: CGSize(width: width, height: height))
                } catch let error {
                    print(error)
                }
            }
        }
    }
}

struct VirtualMachineConfiguration {
    let widthInPixels: Int
    let heightInPixels: Int
    
    private var vmBundlePath: String {
        return NSHomeDirectory() + "/VM.bundle/"
    }

    private var vmBundleURL: URL {
        return URL(fileURLWithPath: vmBundlePath)
    }

    private var auxiliaryStorageURL: URL {
        return vmBundleURL.appendingPathComponent("AuxiliaryStorage")
    }

    private var diskImageURL: URL {
        return vmBundleURL.appendingPathComponent("Disk.img")
    }

    private var hardwareModelURL: URL {
        return vmBundleURL.appendingPathComponent("HardwareModel")
    }

    private var machineIdentifierURL: URL {
        return vmBundleURL.appendingPathComponent("MachineIdentifier")
    }

    private var restoreImageURL: URL {
        return vmBundleURL.appendingPathComponent("RestoreImage.ipsw")
    }

    public var saveFileURL: URL {
        return vmBundleURL.appendingPathComponent("SaveFile.vzvmsave")
    }

    func createMacPlatform() -> VZMacPlatformConfiguration {
        let macPlatform = VZMacPlatformConfiguration()

        let auxiliaryStorage = VZMacAuxiliaryStorage(contentsOf: auxiliaryStorageURL)
        macPlatform.auxiliaryStorage = auxiliaryStorage

        if !FileManager.default.fileExists(atPath: vmBundlePath) {
            fatalError("Missing Virtual Machine Bundle at \(vmBundlePath). Run InstallationTool first to create it.")
        }

        guard let hardwareModelData = try? Data(contentsOf: hardwareModelURL) else {
            fatalError("Failed to retrieve hardware model data.")
        }

        guard let hardwareModel = VZMacHardwareModel(dataRepresentation: hardwareModelData) else {
            fatalError("Failed to create hardware model.")
        }

        if !hardwareModel.isSupported {
            fatalError("The hardware model isn't supported on the current host")
        }
        macPlatform.hardwareModel = hardwareModel

        guard let machineIdentifierData = try? Data(contentsOf: machineIdentifierURL) else {
            fatalError("Failed to retrieve machine identifier data.")
        }

        guard let machineIdentifier = VZMacMachineIdentifier(dataRepresentation: machineIdentifierData) else {
            fatalError("Failed to create machine identifier.")
        }
        macPlatform.machineIdentifier = machineIdentifier

        return macPlatform
    }

    func createVirtualMachine() -> VZVirtualMachineConfiguration {
        let virtualMachineConfiguration = VZVirtualMachineConfiguration()

        virtualMachineConfiguration.platform = createMacPlatform()
        virtualMachineConfiguration.bootLoader = MacOSVirtualMachineConfigurationHelper.createBootLoader()
        virtualMachineConfiguration.cpuCount = MacOSVirtualMachineConfigurationHelper.computeCPUCount()
        virtualMachineConfiguration.memorySize = MacOSVirtualMachineConfigurationHelper.computeMemorySize()
        virtualMachineConfiguration.graphicsDevices = [MacOSVirtualMachineConfigurationHelper.createGraphicsDeviceConfiguration(diskImageURL: diskImageURL, width: widthInPixels, height: heightInPixels)]
        virtualMachineConfiguration.storageDevices = [MacOSVirtualMachineConfigurationHelper.createBlockDeviceConfiguration(diskImageURL: diskImageURL)]
        virtualMachineConfiguration.networkDevices = [MacOSVirtualMachineConfigurationHelper.createNetworkDeviceConfiguration()]
        virtualMachineConfiguration.socketDevices = [MacOSVirtualMachineConfigurationHelper.createSocketDeviceConfiguration()]
        virtualMachineConfiguration.pointingDevices = [MacOSVirtualMachineConfigurationHelper.createPointingDeviceConfiguration()]
        virtualMachineConfiguration.keyboards = [MacOSVirtualMachineConfigurationHelper.createKeyboardConfiguration()]

        try! virtualMachineConfiguration.validate()

        if #available(macOS 14.0, *) {
            try! virtualMachineConfiguration.validateSaveRestoreSupport()
        }
        
        return virtualMachineConfiguration
    }
}
