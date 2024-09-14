//
//  Vibe_AnimationApp.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI
import AppKit

enum AppFlowState {
    case initialize
    case launch
    case configure
    case main
}

enum AppFlowEvent {
    case initialized
    case launched
    case configured
}

struct AppFlowStateMachine {
    var currentState: AppFlowState = .initialize
    
    mutating func handleEvent(_ event: AppFlowEvent) {
        switch (currentState, event) {
        case (.initialize, .initialized):
            transition(to: .launch)
        case (.launch, .launched):
            transition(to: .configure)
        case (.configure, .configured):
            transition(to: .main)
        default:
            // - TODO: Remove fatalError before production!
            fatalError("currentState: \(currentState) event: \(event)")
        }
    }
    
    private mutating func transition(to newState: AppFlowState) {
        currentState = newState
    }
}

final class VibeAppVM: ObservableObject {
    @Published var appStateMachine = AppFlowStateMachine()
    @Published var framework: SetupFlowFramework = .react
    
    func handleEvent(_ event: AppFlowEvent) {
        appStateMachine.handleEvent(event)
    }
}

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
            switch vm.appStateMachine.currentState {
            case .initialize:
                Text("Initialize")
                    .task {
                        vm.handleEvent(.initialized)
                    }
            case .launch, .configure:
                let projectsContainerSize = CGSize(width: 775, height: 445)
                
                ProjectsContainerView(width: projectsContainerSize.width, height: projectsContainerSize.height) {
                    SetupFlowContainerScreen { framework in
                        vm.framework = framework
                        vm.handleEvent(.configured)
                    }
                }
                .preferredColorScheme(.dark)
                .task {
                    vm.handleEvent(.launched)
                }
                .onAppear {
                    setWindowPositionForSize(x: projectsContainerSize.width, y: projectsContainerSize.height)
                }
            case .main:
                let editorViewMinimumSize = CGSize(width: 1500, height: 900)
                
                EditorView(framework: vm.framework)
                    .frame(minWidth: editorViewMinimumSize.width, minHeight: editorViewMinimumSize.height)
                    .preferredColorScheme(.dark)
                    .onAppear {
                        setWindowPositionForSize(x: editorViewMinimumSize.width, y: editorViewMinimumSize.height)
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
