//
//  SetupFlow.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 8/28/24.
//

import SwiftUI

enum SetupFlowState: Hashable {
    case start
//    case chooseFramework
    case projectInfo
//    case configurationReact
//    case projectInfoAndroid
//    case compilationMode
//    case xcodeCheck
//    case configurationSwiftUI
//    case swiftUICopying
//    case swiftUICompile
    case projectLoad
    case browsingProject
    case complete
//    case swiftUIInstallImage
}

enum SetupFlowEvent {
    case newProject
    case openProject
//    case continueSetupReact
//    case continueSetupSwiftUI
//    case continueSetupCompose
    case continueSetup
    case asyncJobFinished
    case filePicked
    case cancelSetup
    case cancelImageInstall
    case back
}

class SetupFlowStateMachine: ObservableObject {
    @Published private(set) var currentState: SetupFlowState = .start
    private var stateHistory: [SetupFlowState] = []
    
    func handleEvent(_ event: SetupFlowEvent) {
        switch (currentState, event) {
        // Open project flow
        case (.start, .openProject):
            transition(to: .browsingProject)
        case (.browsingProject, .cancelSetup):
            transition(to: .start)
        case (.browsingProject, .filePicked):
            transition(to: .projectLoad)
        case (.projectLoad, .cancelSetup):
            transition(to: .start)
        case (.projectLoad, .asyncJobFinished):
            transition(to: .complete)
        case (.start, .newProject):
            transition(to: .projectInfo)
        // New project flow
        case (.projectInfo, .continueSetup):
            transition(to: .complete)
//        case (.projectInfoAndroid, .continueSetupCompose):
//            transition(to: .complete)
//        case (.compilationMode, .continueSetupSwiftUI):
//            transition(to: .xcodeCheck)
//        case (.xcodeCheck, .continueSetupSwiftUI):
//            transition(to: .swiftUICopying)
//        case (.swiftUICopying, .asyncJobFinished):
//            transition(to: .swiftUICompile)
//        case (.swiftUICompile, .asyncJobFinished):
//            transition(to: .swiftUIInstallImage)
//        case (.swiftUIInstallImage, .asyncJobFinished):
//            transition(to: .complete)
//        case (.swiftUIInstallImage, .cancelSetup):
//            transition(to: .start)
//        case (.swiftUICopying, .cancelSetup):
//            transition(to: .start)
//        case (.swiftUICompile, .cancelSetup):
//            transition(to: .start)
        // Shared flow
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
