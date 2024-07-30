//
//  Vibe_AnimationApp.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

@main
struct Vibe_AnimationApp: App {
    @State private var isShowingLaunchView = false
    var body: some Scene {
        WindowGroup {
            if isShowingLaunchView {
                LaunchFlowView()
                    .frame(width: 775, height: 445)
            } else {
                ContentView()
            }
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

private struct AppColorsKey: EnvironmentKey {
    static let defaultValue: Colors = ColorsLight()
}

extension EnvironmentValues {
    var appColors: Colors {
        get { self[AppColorsKey.self] }
        set { self[AppColorsKey.self] = newValue }
    }
}
