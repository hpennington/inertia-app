//
//  PlaybackManager.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import Foundation
import Observation
import Inertia

@Observable
@MainActor
final class PlaybackManager {
    var isPlaying: Bool = false
    var playheadTime: CGFloat = .zero
    var previousPlayheadTime: [InertiaID: CGFloat] = [:] // Per-actionable previous playhead time
    var keyframes: [InertiaID: [InertiaAnimationKeyframe]] = [:] {
        didSet {
            onKeyframesChanged?()
        }
    }

    private var animations: [InertiaID: InertiaAnimationSchema]
    private let serverManager: WebSocketServerManager
    private var framework: SetupFlowFramework
    private var onKeyframesChanged: (() -> Void)?

    init(animations: [InertiaID: InertiaAnimationSchema], serverManager: WebSocketServerManager, framework: SetupFlowFramework) {
        self.animations = animations
        self.serverManager = serverManager
        self.framework = framework
    }

    func updateFramework(_ framework: SetupFlowFramework) {
        self.framework = framework
    }

    func updateAnimations(_ animations: [InertiaID: InertiaAnimationSchema]) {
        self.animations = animations
    }

    func setKeyframesChangedHandler(_ handler: @escaping () -> Void) {
        self.onKeyframesChanged = handler
    }

    func runInvokePlayback() async -> Bool {
        let containerId = "animation"

        let schemaWrappers = animations.compactMap { (key: InertiaID, schema: InertiaAnimationSchema) -> InertiaSchemaWrapper? in
            let container = AnimationContainer(
                actionableId: key,
                containerId: containerId
            )

            return InertiaSchemaWrapper(
                schema: schema,
                actionableId: key,
                container: container,
                animationId: schema.id
            )
        }

        let result = serverManager.sendSchema(schemaWrappers, to: framework)

        switch result {
        case .success(let success):
            return success == 1
        case .failure(let failure):
            print(failure)
            return false
        }
    }

    func play() async {
        print(await runInvokePlayback())
    }
}
