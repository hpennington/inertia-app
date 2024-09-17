//
//  Vibe_AnimationApp.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

@main
struct Vibe_AnimationApp: App {
    @StateObject private var vm = VibeAppVM()
    
    func setWindowPositionForSize(x: CGFloat, y: CGFloat) {
        guard let window = NSApp.mainWindow else {
            return
        }
        
        guard let screenSize = NSScreen.main?.visibleFrame.size else {
            return
        }
        
        let originX = (screenSize.width - x) / 2
        let originY = (screenSize.height - y) / 2 + (y / 2) // - TODO: Investigate this line for correct vertical centering of a window
        
        window.setFrameOrigin(NSPoint(x: originX, y: originY))
    }
    
    var body: some Scene {
        WindowGroup {
            switch vm.stateMachine.currentState {
            case .complete:
                if let url = vm.setupFlowManager.reactProjectURL {
                    let editorViewMinimumSize = CGSize(width: 1500, height: 900)
                    EditorView(url: url, framework: vm.framework, animations: vm.animations)
                        .frame(minWidth: editorViewMinimumSize.width, minHeight: editorViewMinimumSize.height)
                        .preferredColorScheme(.dark)
                        .onAppear {
                            setWindowPositionForSize(x: editorViewMinimumSize.width, y: editorViewMinimumSize.height)
                        }
                }
            default:
                let projectsContainerSize = CGSize(width: 775, height: 445)
                
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
                .preferredColorScheme(.dark)
                .onAppear {
                    setWindowPositionForSize(x: projectsContainerSize.width, y: projectsContainerSize.height)
                }
            }
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
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
