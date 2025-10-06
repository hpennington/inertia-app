//
//  InertiaAppVM.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 9/15/24.
//

import Combine
import SwiftUI
import WebKit
import Inertia

@MainActor
final class InertiaAppVM: ObservableObject {
    @Published var framework: SetupFlowFramework = .react
    @Published private(set) var stateMachine = SetupFlowStateMachine()
    @Published var navigationPath = NavigationPath()
    @Published var setupFlowManager = SetupFlowManager()
    @Published var animations: [InertiaAnimationSchema] = []

    private var anyCancellable: Set<AnyCancellable> = Set()
    private var event: SetupFlowEvent? = nil

    let configuration = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    let coordinator: WKWebViewWrapper.Coordinator
    let webView: WKWebView

    // Editor view model - created once at init
    let editorViewModel: EditorViewModel

    init() {
        // Initialize properties in order
        coordinator = WKWebViewWrapper.Coordinator()
        configuration.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.underPageBackgroundColor = .black

        // Initialize editor view model
        editorViewModel = EditorViewModel(framework: .react)

        // Set animations binding after initialization
        editorViewModel.setAnimationsBinding(Binding(
            get: { [weak self] in self?.animations ?? [] },
            set: { [weak self] newValue in self?.animations = newValue }
        ))

        // Setup Combine subscriptions
        self.stateMachine.$currentState.sink { [weak self] newState in
            guard let self = self else { return }
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

        // Sync animations changes to editor view model
        self.$animations.sink { [weak self] newAnimations in
            guard let self = self else { return }
            // Convert array to dictionary for editor view model
            let animationsDict = Dictionary(
                uniqueKeysWithValues: newAnimations.map { (InertiaID($0.id), $0) }
            )
            self.editorViewModel.animations = animationsDict
            self.editorViewModel.playbackManager.updateAnimations(animationsDict)
            self.editorViewModel.keyframeHandler.updateAnimations(animationsDict)
        }
        .store(in: &anyCancellable)
    }
    
    func handleEvent(_ event: SetupFlowEvent) {
        self.event = event
        stateMachine.handleEvent(event)
    }
}
