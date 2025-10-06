//
//  LinuxVMView.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI
import Virtualization
import Inertia

@MainActor
struct LinuxVMView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isLoaded: Bool
    @Binding var virtualMachine: VZVirtualMachine?
    @Binding var frameSize: CGSize?
    @Binding var servers: [SetupFlowFramework: WebSocketServer]

    let viewportMinimumSize: CGSize
    let renderViewportCornerRadius: CGFloat
    let delegate: AppDelegate
    let onKeyframeMessage: (WebSocketClient.MessageTranslation, InertiaAnimationValues?) -> Void

    @State private var installerFactoryLinux: LinuxVMFactory?

    private func maxCGSize(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
    }

    var body: some View {
        VStack {
            if isLoaded {
                if let virtualMachine {
                    GeometryReader { proxy in
                        MacRenderView(virtualMachine: virtualMachine, paths: VirtualMachinePaths(system: .linux), size: viewportMinimumSize)
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
                    .onAppear {
                        if servers[.compose] == nil {
                            if let server = try? WebSocketServer(port: 8070) { message in
                                onKeyframeMessage(message, nil)
                            } {
                                server.start()
                                servers[.compose] = server
                            }
                        }
                    }
                }
            } else {
                ProgressView()
                    .onAppear {
                        let paths = VirtualMachinePaths(system: .linux)
                        self.installerFactoryLinux = LinuxVMFactory(size: viewportMinimumSize, paths: paths)

                        if FileManager.default.fileExists(atPath: paths.diskImageURL.path) {
                            // Linux is already installed, boot normally
                            self.virtualMachine = self.installerFactoryLinux?.createVMForBoot()
                        } else {
                            // Linux not installed, boot from ISO for installation
                            self.virtualMachine = self.installerFactoryLinux?.createVMForInstallation(isoURL: URL("/Users/haydenpennington/Downloads/ubuntu-25.04-desktop-arm64.iso")!)
                        }
                        self.delegate.vmShutdownManagers.append(VirtualMachineShutdownManager(virtualMachine: self.virtualMachine, paths: paths))

                        self.virtualMachine?.start { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success:
                                    self.isLoaded = true
                                case .failure(let error):
                                    print("Failed to start VM: \(error)")
                                }
                            }
                        }
                    }
            }

            Spacer(minLength: .zero)
        }
    }
}
