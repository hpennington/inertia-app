//
//  OpenFlow.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/14/24.
//

import SwiftUI

enum OpenFlowState: Hashable {
    case browsing
    case loading
    case completed
}

enum OpenFlowEvent {
    case load
    case cancel
    case complete
}

class OpenFlowStateMachine: ObservableObject {
    @Published private(set) var currentState: OpenFlowState = .browsing
    private var stateHistory: [OpenFlowState] = []
    
    func handleEvent(_ event: OpenFlowEvent) {
        switch (currentState, event) {
        default:
            // - TODO: Remove fatal error before release
            fatalError("default case hit! currentState: \(currentState) newEvent: \(event)")
        }
    }
    
    private func transition(to newState: OpenFlowState) {
        stateHistory.append(currentState)
        currentState = newState
    }
}
