//
//  LinuxVMInstaller.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 10/29/24.
//  Modified for Linux VM support
//

import Foundation
import SwiftUI
import Virtualization

// MARK: - Linux VM Factory
class LinuxVMFactory {
    init(size: CGSize, paths: VirtualMachinePaths) {
        self.size = size
        self.paths = paths
    }
    
    let size: CGSize
    let paths: VirtualMachinePaths
    
    private func createGenericPlatform() -> VZGenericPlatformConfiguration {
        let platform = VZGenericPlatformConfiguration()
        
        // Create and save machine identifier if it doesn't exist
        if !FileManager.default.fileExists(atPath: paths.machineIdentifierURL.path) {
            let machineIdentifier = VZGenericMachineIdentifier()
            try! machineIdentifier.dataRepresentation.write(to: paths.machineIdentifierURL)
            platform.machineIdentifier = machineIdentifier
        } else {
            // Retrieve existing machine identifier
            guard let machineIdentifierData = try? Data(contentsOf: paths.machineIdentifierURL),
                  let machineIdentifier = VZGenericMachineIdentifier(dataRepresentation: machineIdentifierData) else {
                fatalError("Failed to retrieve machine identifier.")
            }
            platform.machineIdentifier = machineIdentifier
        }
        
        return platform
    }
    
    private func createConfiguration(withISO isoURL: URL? = nil) -> VZVirtualMachineConfiguration {
        let virtualMachineConfiguration = VZVirtualMachineConfiguration()
        
        // Use generic platform for Linux
        virtualMachineConfiguration.platform = createGenericPlatform()
        
        // Use EFI boot loader for modern Linux distributions
        virtualMachineConfiguration.bootLoader = LinuxVirtualMachineConfigurationHelper.createBootLoader(efiVariableStoreURL: paths.efiVariableStoreURL)
        
        virtualMachineConfiguration.cpuCount = LinuxVirtualMachineConfigurationHelper.computeCPUCount()
        virtualMachineConfiguration.memorySize = LinuxVirtualMachineConfigurationHelper.computeMemorySize()
        virtualMachineConfiguration.graphicsDevices = [LinuxVirtualMachineConfigurationHelper.createGraphicsDeviceConfiguration(size: size)]
        virtualMachineConfiguration.directorySharingDevices = [LinuxVirtualMachineConfigurationHelper.createSharedDirectory()]
        
        // Storage devices - include ISO if provided for installation
        var storageDevices: [VZStorageDeviceConfiguration] = [LinuxVirtualMachineConfigurationHelper.createBlockDeviceConfiguration(diskImageURL: paths.diskImageURL)]
        if let isoURL = isoURL {
            storageDevices.append(LinuxVirtualMachineConfigurationHelper.createISODeviceConfiguration(isoURL: isoURL))
        }
        virtualMachineConfiguration.storageDevices = storageDevices
        
        virtualMachineConfiguration.networkDevices = [LinuxVirtualMachineConfigurationHelper.createNetworkDeviceConfiguration()]
        virtualMachineConfiguration.socketDevices = [LinuxVirtualMachineConfigurationHelper.createSocketDeviceConfiguration()]
        virtualMachineConfiguration.pointingDevices = [LinuxVirtualMachineConfigurationHelper.createPointingDeviceConfiguration()]
        virtualMachineConfiguration.keyboards = [LinuxVirtualMachineConfigurationHelper.createKeyboardConfiguration()]
        virtualMachineConfiguration.audioDevices = LinuxVirtualMachineConfigurationHelper.createAudioDeviceConfigurations()
        virtualMachineConfiguration.consoleDevices = [LinuxVirtualMachineConfigurationHelper.createSpiceAgentConsoleDeviceConfiguration()]

        try! virtualMachineConfiguration.validate()
        
        if #available(macOS 14.0, *) {
            try! virtualMachineConfiguration.validateSaveRestoreSupport()
        }
        
        return virtualMachineConfiguration
    }
    
    func createVMForInstallation(isoURL: URL) -> VZVirtualMachine {
        if !FileManager.default.fileExists(atPath: paths.vmBundleURL.path) {
            createVMBundle()
        }
        if !FileManager.default.fileExists(atPath: paths.diskImageURL.path) {
            createDiskImage()
        }
        
        return VZVirtualMachine(configuration: createConfiguration(withISO: isoURL))
    }
    
    func createVMForBoot() -> VZVirtualMachine {
        guard FileManager.default.fileExists(atPath: paths.diskImageURL.path) else {
            // For uninstalled systems, create a basic VM that can be used later
            return VZVirtualMachine(configuration: createConfiguration())
        }
        
        return VZVirtualMachine(configuration: createConfiguration())
    }
    
    private func createVMBundle() {
        let bundleFd = mkdir(paths.vmBundlePath, S_IRWXU | S_IRWXG | S_IRWXO)
        if bundleFd == -1 {
            if errno == EEXIST {
                return // Bundle already exists, that's fine
            }
            fatalError("Failed to create VM.bundle.")
        }

        let result = close(bundleFd)
        if result != 0 {
            fatalError("Failed to close VM.bundle.")
        }
    }

    // Create an empty disk image for the virtual machine.
    private func createDiskImage() {
        let diskFd = open(paths.diskImageURL.path, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR)
        if diskFd == -1 {
            fatalError("Cannot create disk image.")
        }

        // 64 GB disk space (smaller than macOS default)
        var result = ftruncate(diskFd, 64 * 1024 * 1024 * 1024)
        if result != 0 {
            fatalError("ftruncate() failed.")
        }

        result = close(diskFd)
        if result != 0 {
            fatalError("Failed to close the disk image.")
        }
    }
}

// MARK: - Linux VM Configuration Helper
class LinuxVirtualMachineConfigurationHelper {
    
    static func createBootLoader(efiVariableStoreURL: URL) -> VZEFIBootLoader {
        let bootLoader = VZEFIBootLoader()
        
        // Create EFI variable store if it doesn't exist
        if !FileManager.default.fileExists(atPath: efiVariableStoreURL.path) {
            do {
                try VZEFIVariableStore(creatingVariableStoreAt: efiVariableStoreURL)
            } catch {
                fatalError("Failed to create EFI variable store: \(error.localizedDescription)")
            }
        }
        
        // Load the existing variable store
        bootLoader.variableStore = VZEFIVariableStore(url: efiVariableStoreURL)
        
        return bootLoader
    }
    
    static func computeCPUCount() -> Int {
        let totalAvailableCPUs = ProcessInfo.processInfo.processorCount
        var virtualCPUCount = totalAvailableCPUs <= 1 ? 1 : totalAvailableCPUs - 1
        virtualCPUCount = max(virtualCPUCount, VZVirtualMachineConfiguration.minimumAllowedCPUCount)
        virtualCPUCount = min(virtualCPUCount, VZVirtualMachineConfiguration.maximumAllowedCPUCount)
        return virtualCPUCount
    }

    static func computeMemorySize() -> UInt64 {
        // 4GB default for Linux
        var memorySize = (4 * 1024 * 1024 * 1024) as UInt64
        memorySize = max(memorySize, VZVirtualMachineConfiguration.minimumAllowedMemorySize)
        memorySize = min(memorySize, VZVirtualMachineConfiguration.maximumAllowedMemorySize)
        return memorySize
    }

    static func createBlockDeviceConfiguration(diskImageURL: URL) -> VZVirtioBlockDeviceConfiguration {
        guard let diskImageAttachment = try? VZDiskImageStorageDeviceAttachment(url: diskImageURL, readOnly: false) else {
            fatalError("Failed to create disk image attachment.")
        }
        let disk = VZVirtioBlockDeviceConfiguration(attachment: diskImageAttachment)
        return disk
    }
    
    static func createISODeviceConfiguration(isoURL: URL) -> VZStorageDeviceConfiguration {
        guard let isoAttachment = try? VZDiskImageStorageDeviceAttachment(url: isoURL, readOnly: true) else {
            fatalError("Failed to create ISO attachment.")
        }
        return VZUSBMassStorageDeviceConfiguration(attachment: isoAttachment)
    }

    static func createGraphicsDeviceConfiguration(size: CGSize) -> VZVirtioGraphicsDeviceConfiguration {
        let graphicsConfiguration = VZVirtioGraphicsDeviceConfiguration()
        graphicsConfiguration.scanouts = [
            VZVirtioGraphicsScanoutConfiguration(widthInPixels: Int(size.width), heightInPixels: Int(size.height))
        ]
        return graphicsConfiguration
    }

    static func createNetworkDeviceConfiguration() -> VZVirtioNetworkDeviceConfiguration {
        let networkDevice = VZVirtioNetworkDeviceConfiguration()
        networkDevice.macAddress = VZMACAddress(string: "d6:a7:58:8e:78:d4")!
        let networkAttachment = VZNATNetworkDeviceAttachment()
        networkDevice.attachment = networkAttachment
        return networkDevice
    }

    static func createPointingDeviceConfiguration() -> VZUSBScreenCoordinatePointingDeviceConfiguration {
        return VZUSBScreenCoordinatePointingDeviceConfiguration()
    }

    static func createKeyboardConfiguration() -> VZUSBKeyboardConfiguration {
        return VZUSBKeyboardConfiguration()
    }

    static func createAudioDeviceConfigurations() -> [VZVirtioSoundDeviceConfiguration] {
        let inputAudioDevice = VZVirtioSoundDeviceConfiguration()
        let inputStream = VZVirtioSoundDeviceInputStreamConfiguration()
        inputStream.source = VZHostAudioInputStreamSource()
        inputAudioDevice.streams = [inputStream]
        
        let outputAudioDevice = VZVirtioSoundDeviceConfiguration()
        let outputStream = VZVirtioSoundDeviceOutputStreamConfiguration()
        outputStream.sink = VZHostAudioOutputStreamSink()
        outputAudioDevice.streams = [outputStream]
        
        return [inputAudioDevice, outputAudioDevice]
    }

    static func createSpiceAgentConsoleDeviceConfiguration() -> VZVirtioConsoleDeviceConfiguration {
        let consoleDevice = VZVirtioConsoleDeviceConfiguration()
        
        let spiceAgentPort = VZVirtioConsolePortConfiguration()
        spiceAgentPort.name = VZSpiceAgentPortAttachment.spiceAgentPortName
        spiceAgentPort.attachment = VZSpiceAgentPortAttachment()
        consoleDevice.ports[0] = spiceAgentPort
        
        return consoleDevice
    }

    static func createSocketDeviceConfiguration() -> VZVirtioSocketDeviceConfiguration {
        let socketDevice = VZVirtioSocketDeviceConfiguration()
        return socketDevice
    }

    static func createSharedDirectory() -> VZVirtioFileSystemDeviceConfiguration {
        let directoryURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appending(path: "InertiaStorage", directoryHint: .isDirectory)
        let sharedDirectoryShare = VZSingleDirectoryShare(directory: VZSharedDirectory(url: directoryURL, readOnly: false))
        let sharedDirectoryConfiguration = VZVirtioFileSystemDeviceConfiguration(tag: "inertia_storage")
        sharedDirectoryConfiguration.share = sharedDirectoryShare
        return sharedDirectoryConfiguration
    }
}
