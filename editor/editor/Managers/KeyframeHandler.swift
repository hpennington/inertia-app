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

    func createKeyframe(message: WebSocketClient.MessageTranslation, initialValues: InertiaAnimationValues? = nil, isRecording: Bool) {
        print(message)
        print(animations)

        let values = InertiaAnimationValues(
            scale: 1.0,
            translate: .init(width: message.translationX, height: message.translationY),
            rotate: .zero,
            rotateCenter: .zero,
            opacity: 1.0
        )
        
        
        let defaultInitialValue: InertiaAnimationValues = {
            if playbackManager.playheadTime == .zero {
                let initialValues = InertiaAnimationValues(
                    scale: 1.0,
                    translate: .init(width: message.translationX, height: message.translationY),
                    rotate: .zero,
                    rotateCenter: .zero,
                    opacity: 1.0
                )
                return initialValues
            } else {
                let initialValues = InertiaAnimationValues(
                    scale: 1.0,
                    translate: .zero,
                    rotate: .zero,
                    rotateCenter: .zero,
                    opacity: 1.0
                )
                return initialValues
            }
        }()

        var updatedAnimationsArray: [InertiaAnimationSchema] = Array(animations.values)

        // Create keyframe for each selected actionable ID
        for pair in message.actionableIds {
            let hierarchyId = pair.hierarchyId
            let hierarchyIdPrefix = pair.hierarchyIdPrefix
            let hierarchyIdForKeyframes = InertiaID(hierarchyId)
            let hierarchyIdPrefixForSchema = InertiaID(hierarchyIdPrefix)

            // Get previous playhead time for this specific actionable (using hierarchyId for instance-specific tracking)
            let previousTime = playbackManager.previousPlayheadTime[hierarchyIdForKeyframes] ?? 0.0

            // Only create and append keyframe if recording is enabled
            if isRecording {
                let newKeyframe = InertiaAnimationKeyframe(
                    id: UUID().uuidString,
                    values: values,
                    duration: playbackManager.playheadTime - previousTime
                )

                // Update previous playhead time for this actionable
                playbackManager.previousPlayheadTime[hierarchyIdForKeyframes] = playbackManager.playheadTime

                // Append keyframe to this actionable's keyframes array (using hierarchyId for instance-specific keyframes)
                if playbackManager.keyframes[hierarchyIdForKeyframes] == nil {
                    playbackManager.keyframes[hierarchyIdForKeyframes] = []
                }
                playbackManager.keyframes[hierarchyIdForKeyframes]?.append(newKeyframe)
            }

            // Get keyframes for this specific actionable instance
            let actionableKeyframes = playbackManager.keyframes[hierarchyIdForKeyframes] ?? []

            let animationSchema = InertiaAnimationSchema(
                id: hierarchyIdPrefix,
                initialValues: initialValues ?? defaultInitialValue,
                invokeType: .auto,
                keyframes: actionableKeyframes
            )

            if let animationIndex = updatedAnimationsArray.firstIndex(where: { schema in
                schema.id == hierarchyIdPrefix
            }) {
                updatedAnimationsArray[animationIndex] = animationSchema
            } else {
                updatedAnimationsArray.append(animationSchema)
            }

            // Update local animations dict (using hierarchyIdPrefix for schema storage)
            animations[hierarchyIdPrefixForSchema] = animationSchema
        }

        // Notify parent of animations update
        onAnimationsUpdate?(updatedAnimationsArray)
    }
}
