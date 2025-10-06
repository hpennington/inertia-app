//
//  KeyframeHandler.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import Foundation
import SwiftUI
import Inertia

@MainActor
final class KeyframeHandler {
    private let editorModel: EditorModel
    private let playbackManager: PlaybackManager
    @Binding private var animations: [InertiaAnimationSchema]

    init(editorModel: EditorModel, playbackManager: PlaybackManager, animations: Binding<[InertiaAnimationSchema]>) {
        self.editorModel = editorModel
        self.playbackManager = playbackManager
        self._animations = animations
    }

    func createKeyframe(message: WebSocketClient.MessageTranslation, initialValues: InertiaAnimationValues? = nil) {
        print(message)
        print(animations)

        let values = InertiaAnimationValues(
            scale: 1.0,
            translate: .init(width: message.translationX, height: message.translationY),
            rotate: .zero,
            rotateCenter: .zero,
            opacity: 1.0
        )

        let newKeyframe = InertiaAnimationKeyframe(
            id: UUID().uuidString,
            values: values,
            duration: playbackManager.playheadTime - playbackManager.previousPlayheadTime
        )
        playbackManager.previousPlayheadTime = playbackManager.playheadTime
        playbackManager.keyframes.append(newKeyframe)

        let initialValues = initialValues ?? InertiaAnimationValues(
            scale: 1.0,
            translate: .zero,
            rotate: .zero,
            rotateCenter: .zero,
            opacity: 1.0
        )

        for id in message.actionableIds {
            let animationSchema = InertiaAnimationSchema(
                id: id,
                initialValues: initialValues,
                invokeType: .auto,
                keyframes: playbackManager.keyframes
            )

            if let animationIndex = animations.firstIndex(where: { schema in
                schema.id == id
            }) {
                animations[animationIndex] = animationSchema
            } else {
                animations.append(animationSchema)
                editorModel.animations[InertiaID(id)] = animationSchema
            }
        }
    }
}
