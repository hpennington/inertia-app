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
    var previousPlayheadTime: CGFloat = .zero
    var keyframes: [InertiaAnimationKeyframe] = []

    private let editorModel: EditorModel
    private let serverManager: WebSocketServerManager
    private var framework: SetupFlowFramework

    init(editorModel: EditorModel, serverManager: WebSocketServerManager, framework: SetupFlowFramework) {
        self.editorModel = editorModel
        self.serverManager = serverManager
        self.framework = framework
    }

    func updateFramework(_ framework: SetupFlowFramework) {
        self.framework = framework
    }

    func runInvokePlayback() async -> Bool {
        let containerId = "animation"

        let schemaWrappers = editorModel.animations.compactMap { (key: InertiaID, schema: InertiaAnimationSchema) -> InertiaSchemaWrapper? in
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
