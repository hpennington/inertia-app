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

struct MacOSVirtualMachineConfigurationHelper {
    static func computeCPUCount() -> Int {
        let totalAvailableCPUs = ProcessInfo.processInfo.processorCount

        var virtualCPUCount = totalAvailableCPUs <= 4 ? 1 : totalAvailableCPUs - 4
        virtualCPUCount = max(virtualCPUCount, VZVirtualMachineConfiguration.minimumAllowedCPUCount)
        virtualCPUCount = min(virtualCPUCount, VZVirtualMachineConfiguration.maximumAllowedCPUCount)

        return virtualCPUCount
    }
    
    static func createSharedDirectory() -> VZVirtioFileSystemDeviceConfiguration {
        let directoryURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appending(path: "Inertia", directoryHint: .isDirectory)
        let sharedDirectory = VZSharedDirectory(url: directoryURL, readOnly: false)
        let singleDirectoryShare = VZSingleDirectoryShare(directory: sharedDirectory)

        print(directoryURL)
        print(sharedDirectory)
        print(singleDirectoryShare)
        // Assign the automount tag to this share. macOS shares automounted directories automatically under /Volumes in the guest.
        let sharingConfiguration = VZVirtioFileSystemDeviceConfiguration(tag: VZVirtioFileSystemDeviceConfiguration.macOSGuestAutomountTag)
        sharingConfiguration.share = singleDirectoryShare


        return sharingConfiguration
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

    static func createGraphicsDeviceConfiguration(diskImageURL: URL, size: CGSize) -> VZMacGraphicsDeviceConfiguration {
        let graphicsConfiguration = VZMacGraphicsDeviceConfiguration()
        graphicsConfiguration.displays = [
            VZMacGraphicsDisplayConfiguration(widthInPixels: Int(size.width * 3), heightInPixels: Int(size.height * 3), pixelsPerInch: pixelsPerInch)
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
