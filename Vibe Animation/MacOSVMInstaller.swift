//
//  MacOSVMInstaller.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 10/29/24.
//

import Foundation
import SwiftUI
import Virtualization

class MacOSVMDownloader {
    init(paths: VirtualMachinePaths, progressCallback: @escaping (_: Int) -> Void) {
        self.paths = paths
        self.progressCallback = progressCallback
    }
    
    let paths: VirtualMachinePaths
    let progressCallback: (_ value: Int) -> Void
    private var downloadObserver: NSKeyValueObservation? = nil
    private var downloadTask: URLSessionDownloadTask? = nil
    // MARK: Observe the download progress.

    public func download(completionHandler: @escaping (VZMacOSRestoreImage, VZMacOSConfigurationRequirements) -> Void) {
        NSLog("Attempting to download latest available restore image.")
        VZMacOSRestoreImage.fetchLatestSupported { (result: Result<VZMacOSRestoreImage, Error>) in
            switch result {
                case let .failure(error):
                    fatalError(error.localizedDescription)

                case let .success(restoreImage):
                    self.downloadRestoreImage(restoreImage: restoreImage, completionHandler: completionHandler)
            }
        }
    }

    // MARK: Download the restore image from the network.
    private func downloadRestoreImage(restoreImage: VZMacOSRestoreImage, completionHandler: @escaping (VZMacOSRestoreImage, VZMacOSConfigurationRequirements) -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: restoreImage.url) { localURL, response, error in
            if let error = error {
                fatalError("Download failed. \(error.localizedDescription).")
            }

            if !FileManager.default.fileExists(atPath: self.paths.vmBundleURL.path()) {
                self.createVMBundle()
            }
            
            if !FileManager.default.fileExists(atPath: self.paths.diskImageURL.path()) {
                self.createDiskImage()
            }
            
            try! FileManager.default.moveItem(at: localURL!, to: self.paths.restoreImageURL)
            let conf = restoreImage.mostFeaturefulSupportedConfiguration!
//            installer.installMacOS(ipswURL: self.paths.diskImageURL, conf: conf)

            completionHandler(restoreImage, conf)
        }

        self.downloadObserver = downloadTask.progress.observe(\.fractionCompleted, options: [.initial, .new]) { (progress, change) in
            self.progressCallback(Int(progress.fractionCompleted * 100.0))
        }
        
        downloadTask.resume()
        self.downloadTask = downloadTask
    }
    
    private func createVMBundle() {
        let bundleFd = mkdir(paths.vmBundlePath, S_IRWXU | S_IRWXG | S_IRWXO)
        if bundleFd == -1 {
            if errno == EEXIST {
                fatalError("Failed to create VM.bundle: the base directory already exists.")
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

        // 128 GB disk space.
        var result = ftruncate(diskFd, 128 * 1024 * 1024 * 1024)
        if result != 0 {
            fatalError("ftruncate() failed.")
        }

        result = close(diskFd)
        if result != 0 {
            fatalError("Failed to close the disk image.")
        }
    }
}

class MacOSVMInstaller {
    init(virtualMachine: VZVirtualMachine, paths: VirtualMachinePaths, progressCallback: @escaping (Int) -> Void) {
        self.virtualMachine = virtualMachine
        self.paths = paths
        self.progressCallback = progressCallback
    }
    
    let virtualMachine: VZVirtualMachine
    let paths: VirtualMachinePaths
    let progressCallback: (_ value: Int) -> Void
    
    private var installationObserver: NSKeyValueObservation?
    public func installMacOS(ipswURL: URL, completion: @escaping () -> Void) {
        NSLog("Attempting to install from IPSW at \(ipswURL).")
        VZMacOSRestoreImage.load(from: ipswURL, completionHandler: { [self](result: Result<VZMacOSRestoreImage, Error>) in
            switch result {
                case let .failure(error):
                    fatalError(error.localizedDescription)

                case let .success(restoreImage):
                    installMacOS(restoreImage: restoreImage, completion: completion)
            }
        })
    }

    // MARK: - Internal helper functions.

    private func installMacOS(restoreImage: VZMacOSRestoreImage, completion: @escaping () -> Void) {
        guard let macOSConfiguration = restoreImage.mostFeaturefulSupportedConfiguration else {
            fatalError("No supported configuration available.")
        }

        if !macOSConfiguration.hardwareModel.isSupported {
            fatalError("macOSConfiguration configuration isn't supported on the current host.")
        }

        DispatchQueue.main.async { [self] in
            
//
//            setupVirtualMachine(macOSConfiguration: macOSConfiguration)
            startInstallation(restoreImageURL: restoreImage.url)
        }
    }
    private func startInstallation(restoreImageURL: URL) {
        let installer = VZMacOSInstaller(virtualMachine: virtualMachine, restoringFromImageAt: restoreImageURL)

        NSLog("Starting installation.")
        installer.install(completionHandler: { (result: Result<Void, Error>) in
            if case let .failure(error) = result {
                fatalError(error.localizedDescription)
            } else {
                NSLog("Installation succeeded.")
            }
        })

        // Observe installation progress.
        installationObserver = installer.progress.observe(\.fractionCompleted, options: [.initial, .new]) { (progress, change) in
            NSLog("Installation progress: \(change.newValue! * 100).")
            self.progressCallback(Int(progress.fractionCompleted * 100))
        }
    }
    
    func install(installCompletion: @escaping () -> Void) {
        installMacOS(ipswURL: paths.restoreImageURL, completion: installCompletion)
    }
}

class MacOSVMFactory {
    init(size: CGSize, paths: VirtualMachinePaths) {
        self.size = size
        self.paths = paths
    }
    
    let size: CGSize
    let paths: VirtualMachinePaths
    
    private func createMacPlatform(requirements: VZMacOSConfigurationRequirements) -> VZMacPlatformConfiguration {
        let macPlatformConfiguration = VZMacPlatformConfiguration()

        guard let auxiliaryStorage = try? VZMacAuxiliaryStorage(creatingStorageAt: paths.auxiliaryStorageURL,
                                                                    hardwareModel: requirements.hardwareModel,
                                                                          options: []) else {
            fatalError("Failed to create auxiliary storage.")
        }
        macPlatformConfiguration.auxiliaryStorage = auxiliaryStorage
        macPlatformConfiguration.hardwareModel = requirements.hardwareModel
        macPlatformConfiguration.machineIdentifier = VZMacMachineIdentifier()

        // Store the hardware model and machine identifier to disk so that you
        // can retrieve them for subsequent boots.
        try! macPlatformConfiguration.hardwareModel.dataRepresentation.write(to: paths.hardwareModelURL)
        try! macPlatformConfiguration.machineIdentifier.dataRepresentation.write(to: paths.machineIdentifierURL)
        return macPlatformConfiguration
    }
    
    private func creatConfiguration(requirements: VZMacOSConfigurationRequirements) -> VZVirtualMachineConfiguration {
        let virtualMachineConfiguration = VZVirtualMachineConfiguration()
        virtualMachineConfiguration.platform = createMacPlatform(requirements: requirements)
        virtualMachineConfiguration.bootLoader = MacOSVirtualMachineConfigurationHelper.createBootLoader()
        virtualMachineConfiguration.cpuCount = MacOSVirtualMachineConfigurationHelper.computeCPUCount()
        virtualMachineConfiguration.memorySize = MacOSVirtualMachineConfigurationHelper.computeMemorySize()
        virtualMachineConfiguration.graphicsDevices = [MacOSVirtualMachineConfigurationHelper.createGraphicsDeviceConfiguration(diskImageURL: paths.diskImageURL, size: size)]
        virtualMachineConfiguration.storageDevices = [MacOSVirtualMachineConfigurationHelper.createBlockDeviceConfiguration(diskImageURL: paths.diskImageURL)]
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
    
    private func restoreConfiguration() -> VZVirtualMachineConfiguration {
        let virtualMachineConfiguration = VZVirtualMachineConfiguration()
        virtualMachineConfiguration.platform = restoreMacPlaform()
        virtualMachineConfiguration.bootLoader = MacOSVirtualMachineConfigurationHelper.createBootLoader()
        virtualMachineConfiguration.cpuCount = MacOSVirtualMachineConfigurationHelper.computeCPUCount()
        virtualMachineConfiguration.memorySize = MacOSVirtualMachineConfigurationHelper.computeMemorySize()
        virtualMachineConfiguration.graphicsDevices = [MacOSVirtualMachineConfigurationHelper.createGraphicsDeviceConfiguration(diskImageURL: paths.diskImageURL, size: size)]
        virtualMachineConfiguration.storageDevices = [MacOSVirtualMachineConfigurationHelper.createBlockDeviceConfiguration(diskImageURL: paths.diskImageURL)]
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
    
    private func restoreMacPlaform() -> VZMacPlatformConfiguration {
        let macPlatform = VZMacPlatformConfiguration()

        let auxiliaryStorage = VZMacAuxiliaryStorage(contentsOf: paths.auxiliaryStorageURL)
        macPlatform.auxiliaryStorage = auxiliaryStorage

        if !FileManager.default.fileExists(atPath: paths.vmBundlePath) {
            fatalError("Missing Virtual Machine Bundle at \(paths.vmBundlePath). Run InstallationTool first to create it.")
        }

        // Retrieve the hardware model and save this value to disk
        // during installation.
        guard let hardwareModelData = try? Data(contentsOf: paths.hardwareModelURL) else {
            fatalError("Failed to retrieve hardware model data.")
        }

        guard let hardwareModel = VZMacHardwareModel(dataRepresentation: hardwareModelData) else {
            fatalError("Failed to create hardware model.")
        }

        if !hardwareModel.isSupported {
            fatalError("The hardware model isn't supported on the current host")
        }
        macPlatform.hardwareModel = hardwareModel

        // Retrieve the machine identifier and save this value to disk
        // during installation.
        guard let machineIdentifierData = try? Data(contentsOf: paths.machineIdentifierURL) else {
            fatalError("Failed to retrieve machine identifier data.")
        }

        guard let machineIdentifier = VZMacMachineIdentifier(dataRepresentation: machineIdentifierData) else {
            fatalError("Failed to create machine identifier.")
        }
        macPlatform.machineIdentifier = machineIdentifier

        return macPlatform
    }
    
    func restoreVM() -> VZVirtualMachine {
        
        return VZVirtualMachine(configuration: restoreConfiguration())
    }
    
    func createVM(requirements: VZMacOSConfigurationRequirements) -> VZVirtualMachine {
        
        return VZVirtualMachine(configuration: creatConfiguration(requirements: requirements))
    }
}

@Observable
class MacOSVMInstalledFactory {
    init(downloader: MacOSVMDownloader, installer: MacOSVMInstaller? = nil, vm: VZVirtualMachine? = nil, paths: VirtualMachinePaths, progressCallback: @escaping (Int) -> Void) {
        self.downloader = downloader
        self.installer = installer
        self.vm = vm
        self.paths = paths
        self.progressCallback = progressCallback
    }
    
    let downloader: MacOSVMDownloader
    let paths: VirtualMachinePaths
    let progressCallback: (_ value: Int) -> Void
    private var installer: MacOSVMInstaller?
    private var vm: VZVirtualMachine? = nil
    
    func createInitialzedVM(size: CGSize, paths: VirtualMachinePaths, initCompletion: @escaping (VZVirtualMachine) -> Void)  {
        if FileManager.default.fileExists(atPath: paths.diskImageURL.path) {
            let vmFactory = MacOSVMFactory(size: size, paths: paths)
            let vm = vmFactory.restoreVM()
            self.vm = vm
            initCompletion(vm)
        } else {
            downloader.download { restoreImage, requirements in
                let vmFactory = MacOSVMFactory(size: size, paths: paths)
                
                let vm = vmFactory.createVM(requirements: restoreImage.mostFeaturefulSupportedConfiguration!)
                self.vm = vm
                self.installer = MacOSVMInstaller(virtualMachine: vm, paths: paths) { progress in
                    self.progressCallback(progress)
                }
                self.installer?.install {
                    initCompletion(vm)
                }
            }
        }
        
    }
}
