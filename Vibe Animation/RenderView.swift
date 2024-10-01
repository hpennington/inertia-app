//
//  RenderView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import Foundation
import SwiftUI
import WebKit
import Virtualization

//`struct VirtualMachineView: NSViewRepresentable {
//    typealias NSViewType = VZVirtualMachineView
//
//    @ObservedObject var virtualMachineManager: VirtualMachineManager
//
//    init(virtualMachineManager: VirtualMachineManager) {
//        self.virtualMachineManager = virtualMachineManager
//        self.virtualMachineManager.createVirtualMachine()
//    }
//
//    func makeNSView(context: Context) -> NSViewType {
//        let vm = virtualMachineManager.virtualMachine
//        let view = VZVirtualMachineView(frame: .zero)
//        view.virtualMachine = vm
//        return view
//    }
//
//    func updateNSView(_ nsView: NSViewType, context: Context) {}
//
//    class VirtualMachineManager: NSObject, VZVirtualMachineDelegate, ObservableObject {
//        @Published var virtualMachine: VZVirtualMachine?
//
//        private var vmBundlePath: String {
//            return NSHomeDirectory() + "/VM.bundle/"
//        }
//
//        private var vmBundleURL: URL {
//            return URL(fileURLWithPath: vmBundlePath)
//        }
//
//        private var auxiliaryStorageURL: URL {
//            return vmBundleURL.appendingPathComponent("AuxiliaryStorage")
//        }
//
//        private var diskImageURL: URL {
//            return vmBundleURL.appendingPathComponent("Disk.img")
//        }
//
//        private var hardwareModelURL: URL {
//            return vmBundleURL.appendingPathComponent("HardwareModel")
//        }
//
//        private var machineIdentifierURL: URL {
//            return vmBundleURL.appendingPathComponent("MachineIdentifier")
//        }
//
//        private var restoreImageURL: URL {
//            return vmBundleURL.appendingPathComponent("RestoreImage.ipsw")
//        }
//
//        private var saveFileURL: URL {
//            return vmBundleURL.appendingPathComponent("SaveFile.vzvmsave")
//        }
//
//        func createMacPlatform() -> VZMacPlatformConfiguration {
//            let macPlatform = VZMacPlatformConfiguration()
//
//            let auxiliaryStorage = VZMacAuxiliaryStorage(contentsOf: auxiliaryStorageURL)
//            macPlatform.auxiliaryStorage = auxiliaryStorage
//
//            if !FileManager.default.fileExists(atPath: vmBundlePath) {
//                fatalError("Missing Virtual Machine Bundle at \(vmBundlePath). Run InstallationTool first to create it.")
//            }
//
//            guard let hardwareModelData = try? Data(contentsOf: hardwareModelURL) else {
//                fatalError("Failed to retrieve hardware model data.")
//            }
//
//            guard let hardwareModel = VZMacHardwareModel(dataRepresentation: hardwareModelData) else {
//                fatalError("Failed to create hardware model.")
//            }
//
//            if !hardwareModel.isSupported {
//                fatalError("The hardware model isn't supported on the current host")
//            }
//            macPlatform.hardwareModel = hardwareModel
//
//            guard let machineIdentifierData = try? Data(contentsOf: machineIdentifierURL) else {
//                fatalError("Failed to retrieve machine identifier data.")
//            }
//
//            guard let machineIdentifier = VZMacMachineIdentifier(dataRepresentation: machineIdentifierData) else {
//                fatalError("Failed to create machine identifier.")
//            }
//            macPlatform.machineIdentifier = machineIdentifier
//
//            return macPlatform
//        }
//
//        func createVirtualMachine() -> VZVirtualMachine {
//            let virtualMachineConfiguration = VZVirtualMachineConfiguration()
//
//            virtualMachineConfiguration.platform = createMacPlatform()
//            virtualMachineConfiguration.bootLoader = MacOSVirtualMachineConfigurationHelper.createBootLoader()
//            virtualMachineConfiguration.cpuCount = MacOSVirtualMachineConfigurationHelper.computeCPUCount()
//            virtualMachineConfiguration.memorySize = MacOSVirtualMachineConfigurationHelper.computeMemorySize()
//            virtualMachineConfiguration.graphicsDevices = [MacOSVirtualMachineConfigurationHelper.createGraphicsDeviceConfiguration(diskImageURL: diskImageURL)]
//            virtualMachineConfiguration.storageDevices = [MacOSVirtualMachineConfigurationHelper.createBlockDeviceConfiguration(diskImageURL: diskImageURL)]
//            virtualMachineConfiguration.networkDevices = [MacOSVirtualMachineConfigurationHelper.createNetworkDeviceConfiguration()]
//            virtualMachineConfiguration.socketDevices = [MacOSVirtualMachineConfigurationHelper.createSocketDeviceConfiguration()]
//            virtualMachineConfiguration.pointingDevices = [MacOSVirtualMachineConfigurationHelper.createPointingDeviceConfiguration()]
//            virtualMachineConfiguration.keyboards = [MacOSVirtualMachineConfigurationHelper.createKeyboardConfiguration()]
//
//            try! virtualMachineConfiguration.validate()
//
//            if #available(macOS 14.0, *) {
//                try! virtualMachineConfiguration.validateSaveRestoreSupport()
//            }
//
//            virtualMachine = VZVirtualMachine(configuration: virtualMachineConfiguration)
//            virtualMachine?.delegate = self
//            return virtualMachine!
//        }
//
//        func startVirtualMachine() {
//            virtualMachine?.start(completionHandler: { (result) in
//                if case let .failure(error) = result {
//                    fatalError("Virtual machine failed to start with \(error)")
//                }
//            })
//        }
//
//        func resumeVirtualMachine() {
//            virtualMachine?.resume(completionHandler: { (result) in
//                if case let .failure(error) = result {
//                    fatalError("Virtual machine failed to resume with \(error)")
//                }
//            })
//        }
//
//        @available(macOS 14.0, *)
//        func restoreVirtualMachine() {
//            virtualMachine?.restoreMachineStateFrom(url: saveFileURL, completionHandler: { (error) in
//                let fileManager = FileManager.default
//                try! fileManager.removeItem(at: self.saveFileURL)
//
//                if error == nil {
//                    self.resumeVirtualMachine()
//                } else {
//                    self.startVirtualMachine()
//                }
//            })
//        }
//
//        @available(macOS 14.0, *)
//        func saveVirtualMachine(completionHandler: @escaping () -> Void) {
//            virtualMachine?.saveMachineStateTo(url: saveFileURL, completionHandler: { (error) in
//                guard error == nil else {
//                    fatalError("Virtual machine failed to save with \(error!)")
//                }
//                completionHandler()
//            })
//        }
//
//        @available(macOS 14.0, *)
//        func pauseAndSaveVirtualMachine(completionHandler: @escaping () -> Void) {
//            virtualMachine?.pause(completionHandler: { (result) in
//                if case let .failure(error) = result {
//                    fatalError("Virtual machine failed to pause with \(error)")
//                }
//                self.saveVirtualMachine(completionHandler: completionHandler)
//            })
//        }
//
////        func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
////            NSLog("Virtual machine did stop with error: \(error.localizedDescription)")
////            exit(-1)
////        }
////
////        func guestDidStop(_ virtualMachine: VZVirtualMachine) {
////            NSLog("Guest did stop virtual machine.")
////            exit(0)
////        }
//    }
//}
//
struct MacOSVirtualMachineConfigurationHelper {
    static func computeCPUCount() -> Int {
        let totalAvailableCPUs = ProcessInfo.processInfo.processorCount

        var virtualCPUCount = totalAvailableCPUs <= 1 ? 1 : totalAvailableCPUs - 1
        virtualCPUCount = max(virtualCPUCount, VZVirtualMachineConfiguration.minimumAllowedCPUCount)
        virtualCPUCount = min(virtualCPUCount, VZVirtualMachineConfiguration.maximumAllowedCPUCount)

        return virtualCPUCount
    }

    static func computeMemorySize() -> UInt64 {
        var memorySize = (4 * 1024 * 1024 * 1024) as UInt64
        memorySize = max(memorySize, VZVirtualMachineConfiguration.minimumAllowedMemorySize)
        memorySize = min(memorySize, VZVirtualMachineConfiguration.maximumAllowedMemorySize)

        return memorySize
    }

    static func createBootLoader() -> VZMacOSBootLoader {
        return VZMacOSBootLoader()
    }

    static func createGraphicsDeviceConfiguration(diskImageURL: URL, width: Int, height: Int) -> VZMacGraphicsDeviceConfiguration {
        let graphicsConfiguration = VZMacGraphicsDeviceConfiguration()
        graphicsConfiguration.displays = [
            VZMacGraphicsDisplayConfiguration(widthInPixels: width, heightInPixels: height, pixelsPerInch: 284)
//            VZMacGraphicsDisplayConfiguration(widthInPixels: 1350, heightInPixels: 990, pixelsPerInch: 284)
        ]

        return graphicsConfiguration
    }

    static func createBlockDeviceConfiguration(diskImageURL: URL) -> VZVirtioBlockDeviceConfiguration {
        guard let diskImageAttachment = try? VZDiskImageStorageDeviceAttachment(url: diskImageURL, readOnly: false) else {
            fatalError("Failed to create Disk image.")
        }
        let disk = VZVirtioBlockDeviceConfiguration(attachment: diskImageAttachment)
        return disk
    }

    static func createNetworkDeviceConfiguration() -> VZVirtioNetworkDeviceConfiguration {
        let networkDevice = VZVirtioNetworkDeviceConfiguration()
        networkDevice.macAddress = VZMACAddress(string: "d6:a7:58:8e:78:d4")!

        let networkAttachment = VZNATNetworkDeviceAttachment()
        networkDevice.attachment = networkAttachment

        return networkDevice
    }

    static func createSocketDeviceConfiguration() -> VZVirtioSocketDeviceConfiguration {
        return VZVirtioSocketDeviceConfiguration()
    }

    static func createPointingDeviceConfiguration() -> VZPointingDeviceConfiguration {
        return VZMacTrackpadConfiguration()
    }

    static func createKeyboardConfiguration() -> VZKeyboardConfiguration {
        if #available(macOS 14.0, *) {
            return VZMacKeyboardConfiguration()
        } else {
            return VZUSBKeyboardConfiguration()
        }
    }
}
