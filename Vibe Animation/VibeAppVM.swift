//
//  VibeAppVM.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/15/24.
//

import Combine
import SwiftUI
import WebKit
import Vibe

final class VibeAppVM: ObservableObject {
    @Published var framework: SetupFlowFramework = .react
    @Published private(set) var stateMachine = SetupFlowStateMachine()
    @Published var navigationPath = NavigationPath()
    @Published var setupFlowManager = SetupFlowManager()
    @Published var animations: [VibeSchema] = []
    
    private var anyCancellable: Set<AnyCancellable> = Set()
    private var event: SetupFlowEvent? = nil
    
    let configuration = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    
    lazy var webView: WKWebView = {
        WKWebView(frame: .zero, configuration: configuration)
    }()
    
    init() {
        configuration.userContentController = contentController
        webView.underPageBackgroundColor = .black
        
        self.stateMachine.$currentState.sink { newState in
            if let event = self.event {
                switch event {
                case .cancelSetup:
                    self.navigationPath.removeLast(self.navigationPath.count)
                case .back:
                    self.navigationPath.removeLast()
                default:
                    self.navigationPath.append(newState)
                }
            }
        }
        .store(in: &anyCancellable)
    }
    
    func handleEvent(_ event: SetupFlowEvent) {
        self.event = event
        stateMachine.handleEvent(event)
    }
}
