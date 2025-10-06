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
    private var animations: [InertiaID: InertiaAnimationSchema]
    private let playbackManager: PlaybackManager
    private var onAnimationsUpdate: (([InertiaAnimationSchema]) -> Void)?

    init(animations: [InertiaID: InertiaAnimationSchema], playbackManager: PlaybackManager, onAnimationsUpdate: (([InertiaAnimationSchema]) -> Void)? = nil) {
        self.animations = animations
        self.playbackManager = playbackManager
        self.onAnimationsUpdate = onAnimationsUpdate
    }

    func updateAnimations(_ animations: [InertiaID: InertiaAnimationSchema]) {
        self.animations = animations
    }

    func setAnimationsUpdateHandler(_ handler: @escaping ([InertiaAnimationSchema]) -> Void) {
        self.onAnimationsUpdate = handler
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

        var updatedAnimationsArray: [InertiaAnimationSchema] = Array(animations.values)

        for id in message.actionableIds {
            let animationSchema = InertiaAnimationSchema(
                id: id,
                initialValues: initialValues,
                invokeType: .auto,
                keyframes: playbackManager.keyframes
            )

            if let animationIndex = updatedAnimationsArray.firstIndex(where: { schema in
                schema.id == id
            }) {
                updatedAnimationsArray[animationIndex] = animationSchema
            } else {
                updatedAnimationsArray.append(animationSchema)
            }

            // Update local animations dict
            animations[InertiaID(id)] = animationSchema
        }

        // Notify parent of animations update
        onAnimationsUpdate?(updatedAnimationsArray)
    }
}
