//
//  Vibe_AnimationApp.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

@main
struct Vibe_AnimationApp: App {
    @NSApplicationDelegateAdaptor var delegate: AppDelegate
    @StateObject private var vm = VibeAppVM()
    
    func setWindowPositionForSize(x: CGFloat, y: CGFloat) {
        guard let window = NSApp.mainWindow else {
            return
        }
        
        guard let screenSize = NSScreen.main?.visibleFrame.size else {
            return
        }
        
        let originX = (screenSize.width - x) / 2
        let originY = (screenSize.height - y) / 2
        
        window.setFrameOrigin(NSPoint(x: originX, y: originY))
    }
    
    var body: some Scene {
        WindowGroup {
            switch vm.stateMachine.currentState {
            case .complete:
                let editorViewMinimumSize = CGSize(width: 1512, height: 860)
                EditorView(
                    url: $vm.setupFlowManager.reactProjectPath,
                    framework: $vm.framework,
                    animations: $vm.animations,
                    webView: vm.webView,
                    coordinator: vm.coordinator,
                    selectedActionableIDTracker: vm.selectedActionableIDTracker,
                    contentController: vm.contentController,
                    configuration: vm.configuration,
                    delegate: delegate
                )
                    .frame(minWidth: editorViewMinimumSize.width, minHeight: editorViewMinimumSize.height)
                    .task {
                        setWindowPositionForSize(x: editorViewMinimumSize.width, y: editorViewMinimumSize.height)
                    }
            default:
                let projectsContainerSize = CGSize(width: 675, height: 345)
                
                ProjectsContainerView(
                    width: projectsContainerSize.width,
                    height: projectsContainerSize.height
                ) {
                    SetupFlowContainerScreen(
                        navigationPath: $vm.navigationPath,
                        framework: $vm.framework,
                        setupFlowManager: vm.setupFlowManager,
                        animations: $vm.animations
                    ) { event in
                        vm.handleEvent(event)
                    }
                }
//                .preferredColorScheme(.dark)
                .task {
                    setWindowPositionForSize(x: projectsContainerSize.width, y: projectsContainerSize.height)
                }
            }
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1512, height: 900)
        
    }
}

private struct AppColorsKey: EnvironmentKey {
    static let defaultValue: Colors = ColorsLight()
}

private struct PopNavigationStackKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var appColors: Colors {
        get { self[AppColorsKey.self] }
        set { self[AppColorsKey.self] = newValue }
    }
    
    var popNavigationStack: (() -> Void)? {
        get { self[PopNavigationStackKey.self] }
        set { self[PopNavigationStackKey.self] = newValue }
    }
}
import Virtualization

struct VirtualMachineShutdownManager {
    var virtualMachine: VZVirtualMachine? = nil
    var paths: VirtualMachinePaths? = nil

#if arch(arm64)
    @available(macOS 14.0, *)
    func saveVirtualMachine(completionHandler: @escaping () -> Void) {
        if let paths {
            virtualMachine?.saveMachineStateTo(url: paths.saveFileURL, completionHandler: { (error) in
                guard error == nil else {
                    fatalError("Virtual machine failed to save with \(error!)")
                }

                completionHandler()
            })
        }
        
    }

    @available(macOS 14.0, *)
    func pauseAndSaveVirtualMachine(completionHandler: @escaping () -> Void) {
        virtualMachine?.pause(completionHandler: { (result) in
            if case let .failure(error) = result {
                fatalError("Virtual machine failed to pause with \(error)")
            }

            self.saveVirtualMachine(completionHandler: completionHandler)
        })
    }
#endif
    
    func shutdownVM(app: NSApplication) {
#if arch(arm64)
        if #available(macOS 14.0, *) {
            if virtualMachine?.state == .running {
                pauseAndSaveVirtualMachine(completionHandler: {
                    app.reply(toApplicationShouldTerminate: true)
                })
            }
        }
#endif

    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var vmShutdownManagers: [VirtualMachineShutdownManager] = []
    // MARK: Save the virtual machine when the app exits.

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        for vmShutdownManager in vmShutdownManagers {
            vmShutdownManager.shutdownVM(app: sender)
        }
        return .terminateLater
    }
}
