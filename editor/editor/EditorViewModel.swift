//
//  EditorViewModel.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 10/5/25.
//

import SwiftUI
import WebKit
import Virtualization
import Observation
import Inertia

@Observable
@MainActor
final class EditorViewModel {
    // MARK: - State
    var animations: [InertiaID: InertiaAnimationSchema] = [:]
    var isFocused = false
    var frameSize: CGSize? = nil
    var selectedAnimation: String = ""
    var attachActionTitle: String = "Attach Container"
    var isMacOSVMLoaded = false
    var isLinuxVMLoaded = false
    var virtualMachineMacOS: VZVirtualMachine? = nil
    var virtualMachineLinux: VZVirtualMachine? = nil
    var keyframesVersion: Int = 0

    // MARK: - Managers
    var serverManager: WebSocketServerManager
    let playbackManager: PlaybackManager
    let keyframeHandler: KeyframeHandler

    // MARK: - Configuration
    private let framework: SetupFlowFramework
    private var animationsBinding: Binding<[InertiaAnimationSchema]>?

    init(framework: SetupFlowFramework) {
        self.framework = framework
        self.animationsBinding = nil

        // Initialize managers in correct order
        let serverManager = WebSocketServerManager()
        self.serverManager = serverManager

        let playbackManager = PlaybackManager(
            animations: [:],
            serverManager: serverManager,
            framework: framework
        )
        self.playbackManager = playbackManager

        self.keyframeHandler = KeyframeHandler(
            animations: [:],
            playbackManager: playbackManager
        )

        // Set up callback to update animations binding
        keyframeHandler.setAnimationsUpdateHandler { [weak self] updatedAnimations in
            guard let self = self else { return }
            self.animationsBinding?.wrappedValue = updatedAnimations
        }

        // Set up callback to notify when keyframes change
        playbackManager.setKeyframesChangedHandler { [weak self] in
            guard let self = self else { return }
            print("🔥 Keyframes changed! Count: \(self.playbackManager.keyframes.count)")
            self.keyframesVersion += 1
        }

        // Start WebSocket servers for each framework after all properties are initialized
        serverManager.startServer(for: .react, port: 8080) { [weak self] message in
            guard let self = self else { return }
            self.handleKeyframeMessage(message)
        }

        serverManager.startServer(for: .swiftUI, port: 8060) { [weak self] message in
            guard let self = self else { return }
            self.handleKeyframeMessage(message)
        }

        serverManager.startServer(for: .compose, port: 8070) { [weak self] message in
            guard let self = self else { return }
            self.handleKeyframeMessage(message)
        }
    }

    func setAnimationsBinding(_ binding: Binding<[InertiaAnimationSchema]>) {
        self.animationsBinding = binding
    }

    private func handleKeyframeMessage(_ message: WebSocketClient.MessageTranslation) {
        if playbackManager.playheadTime == .zero {
            let initialValues = InertiaAnimationValues(
                scale: 1.0,
                translate: .init(width: message.translationX, height: message.translationY),
                rotate: .zero,
                rotateCenter: .zero,
                opacity: 1.0
            )
            createKeyframe(message: message, initialValues: initialValues)
        } else {
            createKeyframe(message: message, initialValues: nil)
        }
    }

    // MARK: - Computed Properties
    var animationsAvailableContents: [String: [String]] {
        var map: [String: [String]] = [:]
        return map
    }

    var playheadTime: CGFloat {
        playbackManager.playheadTime
    }

    // MARK: - Actions
    func attachAnimation(id: String, actionableIds: Set<String>) {
        // TODO: Implement animation attachment
    }

    func createKeyframe(message: WebSocketClient.MessageTranslation, initialValues: InertiaAnimationValues? = nil) {
        keyframeHandler.createKeyframe(message: message, initialValues: initialValues)
    }

    func play() async {
        await playbackManager.play()
    }

    func updateFramework(_ newFramework: SetupFlowFramework) {
        playbackManager.updateFramework(newFramework)
    }
}
