//
//  MacOSVMView.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI
import Virtualization
import Inertia

@MainActor
struct MacOSVMView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isLoaded: Bool
    @Binding var virtualMachine: VZVirtualMachine?
    @Binding var frameSize: CGSize?
    @Binding var servers: [SetupFlowFramework: WebSocketServer]

    let viewportMinimumSize: CGSize
    let renderViewportCornerRadius: CGFloat
    let delegate: AppDelegate
    let onKeyframeMessage: (WebSocketClient.MessageTranslation, InertiaAnimationValues?) -> Void
    var playheadTime: CGFloat

    @State private var installerFactory: MacOSVMInstalledFactory?

    private func maxCGSize(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
    }

    var body: some View {
        VStack {
            if isLoaded {
                if let virtualMachine {
                    GeometryReader { proxy in
                        MacRenderView(virtualMachine: virtualMachine, paths: VirtualMachinePaths(system: .macos), size: viewportMinimumSize)
                            .onAppear {
                                frameSize = maxCGSize(lhs: proxy.size, rhs: viewportMinimumSize)
                            }
                            .onChange(of: proxy.size) { oldValue, newValue in
                                frameSize = maxCGSize(lhs: newValue, rhs: viewportMinimumSize)
                            }
                    }
                    .aspectRatio(16 / 10, contentMode: .fit)
                    .cornerRadius(renderViewportCornerRadius)
                    .padding(6 / 2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(colorScheme == .light ? ColorPalette.gray5 : ColorPalette.gray2, lineWidth: 6)
                    }
                }
            } else {
                ProgressView()
                    .onAppear {
                        let paths = VirtualMachinePaths(system: .macos)
                        let downloader = MacOSVMDownloader(paths: paths) { value in
                            // progress callback
                        }

                        self.installerFactory = MacOSVMInstalledFactory(downloader: downloader, paths: paths) { progress in
                            // progress callback
                        }
                        self.installerFactory?.createInitialzedVM(size: viewportMinimumSize, paths: paths, initCompletion: { vm in
                            self.virtualMachine = vm
                            self.delegate.vmShutdownManagers.append(VirtualMachineShutdownManager(virtualMachine: vm, paths: paths))
                            self.isLoaded = true
                        })
                    }
            }

            Spacer(minLength: .zero)
        }
    }
}
