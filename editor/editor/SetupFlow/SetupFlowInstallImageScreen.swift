//
//  SetupFlowInstallImageScreen.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 10/31/24.
//

import SwiftUI
import Virtualization

struct SetupFlowInstallImageScreen: View {
    let action: (SetupFlowEvent) -> Void
    
    @State private var progress: CGFloat = .zero
    @State private var installerFactory: MacOSVMInstalledFactory? = nil
    @State private var isDownloadingStep = true
    @State private var virtualMachine: VZVirtualMachine? = nil
    
    var body: some View {
        SetupFlowBase(title: "\(isDownloadingStep ? "Downloading" : "Installing") macOS VM...") {
            VStack(spacing: 16) {
                ProgressView(value: progress)
                
                Spacer()
                SetupActionButton(title: "Cancel", accentColor: ColorPalette.red0) {
                    action(.cancelImageInstall)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .task {
            let paths = VirtualMachinePaths(system: .macos)
            let downloader = MacOSVMDownloader(paths: paths) { value in
                isDownloadingStep = true
                progress = value
            }
            
            self.installerFactory = MacOSVMInstalledFactory(downloader: downloader, paths: paths) { progress in
                isDownloadingStep = false
                self.progress = progress
            }
            
            self.installerFactory?.createInitialzedVM(size: CGSize(width: 1920, height: 1080), paths: paths, initCompletion: { vm in
                self.virtualMachine = vm
//                self.delegate.paths = paths
//                self.delegate.virtualMachine = vm
                action(.asyncJobFinished)
            })
        }
    }
}

#Preview {
    SetupFlowInstallImageScreen { event in
        print(event)
    }
}
