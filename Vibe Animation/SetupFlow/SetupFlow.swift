//
//  SetupFlow.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 8/28/24.
//

import SwiftUI

enum SetupFlowState: Hashable {
    case start
    case chooseFramework
    case projectInfoReact
    case projectInfoIOS
    case configurationReact
    case compilationMode
    case xcodeCheck
    case configurationSwiftUI
    case swiftUICopying
    case swiftUICompile
    case completeSwiftUI
    case completeReact
}

enum SetupFlowEvent {
    case newProject
    case continueSetup
    case continueSetupReact
    case continueSetupSwiftUI
    case asyncJobFinished
    case cancelSetup
    case back
}

class SetupFlowStateMachine: ObservableObject {
    @Published private(set) var currentState: SetupFlowState = .start
    private var stateHistory: [SetupFlowState] = []
    
    func handleEvent(_ event: SetupFlowEvent) {
        switch (currentState, event) {
        case (.start, .newProject):
            transition(to: .chooseFramework)
        case (.chooseFramework, .continueSetupReact):
            transition(to: .projectInfoReact)
        case (.chooseFramework, .continueSetupSwiftUI):
            transition(to: .projectInfoIOS)
        case (.projectInfoReact, .continueSetupReact):
            transition(to: .configurationReact)
        case (.projectInfoIOS, .continueSetupSwiftUI):
            transition(to: .compilationMode)
        case (.configurationReact, .continueSetup):
            transition(to: .completeReact)
        case (.compilationMode, .continueSetup):
            transition(to: .xcodeCheck)
        case (.xcodeCheck, .continueSetup):
            transition(to: .configurationSwiftUI)
        case (.configurationSwiftUI, .continueSetup):
            transition(to: .swiftUICopying)
        case (.swiftUICopying, .asyncJobFinished):
            transition(to: .swiftUICompile)
        case (.swiftUICompile, .asyncJobFinished):
            transition(to: .completeSwiftUI)
        case (.swiftUICopying, .cancelSetup):
            transition(to: .start)
        case (.swiftUICompile, .cancelSetup):
            transition(to: .start)
        case (_, .back):
            if let backState = stateHistory.popLast() {
                currentState = backState
            }
        default:
            // - TODO: Remove fatal error before release
            fatalError("default case hit! currentState: \(currentState) newEvent: \(event)")
        }
    }
    
    private func transition(to newState: SetupFlowState) {
        stateHistory.append(currentState)
        currentState = newState
    }
}
