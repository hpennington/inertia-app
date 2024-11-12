//
//  VirtualMachineView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/24/24.
//

import SwiftUI
import Virtualization

let pixelsPerInch = 284

struct VirtualMachineView: NSViewRepresentable {
    typealias NSViewType = VZVirtualMachineView
    let paths = VirtualMachinePaths()
    let virtualMachine: VZVirtualMachine

    let size: CGSize
    
    init(virtualMachine: VZVirtualMachine, size: CGSize) {
        self.virtualMachine = virtualMachine
        self.size = size
    }
    
    func makeNSView(context: Context) -> NSViewType {
        let virtualMachine = context.coordinator.virtualMachine
        let view = VZVirtualMachineView(frame: .zero)
        view.automaticallyReconfiguresDisplay = true
        view.virtualMachine = virtualMachine
        context.coordinator.startVirtualMachine()
        return view
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        self.refreshDisplaySize(coordinator: context.coordinator)
    }
    
    private func refreshDisplaySize(coordinator: Coordinator) {
        if coordinator.previousSize != size {
            coordinator.updateDisplaySize(sizeInPixels: size)
            coordinator.previousSize = size
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(virtualMachine: virtualMachine, size: size, paths: paths)
    }
    
    class Coordinator: NSObject, VZVirtualMachineDelegate {
        let virtualMachine: VZVirtualMachine
        let size: CGSize
        var previousSize: CGSize? = nil
        let paths: VirtualMachinePaths

        init(virtualMachine: VZVirtualMachine, size: CGSize, paths: VirtualMachinePaths) {
            self.virtualMachine = virtualMachine
            self.size = size
            self.previousSize = size
            self.paths = paths
            super.init()
                
            self.virtualMachine.delegate = self
        }
        
        func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
            print(error)
            pauseAndSaveVirtualMachine {
                
            }
        }
        
        func startVirtualMachine() {
            if FileManager.default.fileExists(atPath: paths.saveFileURL.path) {
                self.restoreVirtualMachine()
            } else {
                self._startVirtualMachine()
            }
        }
        
        func _startVirtualMachine() {
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
            virtualMachine.restoreMachineStateFrom(url: paths.saveFileURL, completionHandler: { [self] (error) in
                // Remove the saved file. Whether success or failure, the state no longer matches the VM's disk.
                let fileManager = FileManager.default
                try? fileManager.removeItem(at: paths.saveFileURL)
                if error == nil {
                    self.resumeVirtualMachine()
                } else {
                    self._startVirtualMachine()
                }
            })
        }

        func saveVirtualMachine(completionHandler: @escaping () -> Void) {
            virtualMachine.saveMachineStateTo(url: paths.saveFileURL, completionHandler: { (error) in
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
        
        func updateDisplaySize(sizeInPixels: CGSize) {
            if let graphicsDevice = virtualMachine.graphicsDevices.first,
            let graphicsDisplay = graphicsDevice.displays.first {
                do {
                    try graphicsDisplay.reconfigure(sizeInPixels: sizeInPixels)
                } catch let error {
                    print(error)
                }
            }
        }
    }
}

struct VirtualMachinePaths {
    var vmBundlePath: String {
        return NSHomeDirectory() + "/VM.bundle/"
    }

    var vmBundleURL: URL {
        return URL(fileURLWithPath: vmBundlePath)
    }

    var auxiliaryStorageURL: URL {
        return vmBundleURL.appendingPathComponent("AuxiliaryStorage")
    }

    var diskImageURL: URL {
        return vmBundleURL.appendingPathComponent("Disk.img")
    }

    var hardwareModelURL: URL {
        return vmBundleURL.appendingPathComponent("HardwareModel")
    }

    var machineIdentifierURL: URL {
        return vmBundleURL.appendingPathComponent("MachineIdentifier")
    }

    var restoreImageURL: URL {
        return vmBundleURL.appendingPathComponent("RestoreImage.ipsw")
    }

    var saveFileURL: URL {
        return vmBundleURL.appendingPathComponent("SaveFile.vzvmsave")
    }
}
