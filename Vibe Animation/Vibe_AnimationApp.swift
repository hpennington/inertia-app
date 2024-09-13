//
//  Vibe_AnimationApp.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

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
    var currentState: AppFlowState = .launch
    
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
    
    var body: some Scene {
        WindowGroup {
            switch vm.appStateMachine.currentState {
            case .initialize:
                Text("Initialize")
                    .task {
                        vm.handleEvent(.initialized)
                    }
            case .launch, .configure:
                ProjectsContainerView {
                    SetupFlowContainerScreen { framework in
                        vm.framework = framework
                        vm.handleEvent(.configured)
                    }
                }
                .preferredColorScheme(.dark)
                .task {
                    vm.handleEvent(.launched)
                }
            case .main:
                EditorView(framework: vm.framework)
                    .frame(minWidth: 1500, minHeight: 900)
                    .preferredColorScheme(.dark)
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
