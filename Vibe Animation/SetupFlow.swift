//
//  SetupFlow.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 8/28/24.
//

import SwiftUI

enum SetupFlowState {
    case start
    case chooseFramework
    case projectInfoReact
    case projectInfoIOS
    case configurationReact
    case compilationMode
    case xcodeCheck
    case swiftUIConfig
    case swiftUICopying
    case swiftUICompile
    case complete
}

enum SetupFlowEvent {
    case continueSetup
    case continueSetupReact
    case continueSetupSwiftUI
    case asyncJobFinished
}

class SetupFlowStateMachine: ObservableObject {
    @Published var currentState: SetupFlowState = .start
    
    func handleEvent(_ event: SetupFlowEvent) {
        switch (currentState, event) {
        case (.start, .continueSetup):
            transition(to: .chooseFramework)
        case (.chooseFramework, .continueSetupReact):
            transition(to: .projectInfoReact)
        case (.chooseFramework, .continueSetupSwiftUI):
            transition(to: .projectInfoIOS)
        case (.projectInfoReact, .continueSetup):
            transition(to: .configurationReact)
        case (.projectInfoIOS, .continueSetup):
            transition(to: .compilationMode)
        case (.configurationReact, .continueSetup):
            transition(to: .compilationMode)
        case (.compilationMode, .continueSetup):
            transition(to: .xcodeCheck)
        case (.xcodeCheck, .asyncJobFinished):
            transition(to: .swiftUIConfig)
        case (.swiftUIConfig, .continueSetup):
            transition(to: .swiftUICopying)
        case (.swiftUICopying, .asyncJobFinished):
            transition(to: .swiftUICompile)
        case (.swiftUICompile, .asyncJobFinished):
            transition(to: .complete)
        default:
            // - TODO: Remove fatal error before release
            fatalError("default case hit!")
            break
        }
    }
    
    private func transition(to newState: SetupFlowState) {
        currentState = newState
        // Handle additional actions for the new state if necessary
    }
}

struct SetupFlow: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SetupFlow()
}
