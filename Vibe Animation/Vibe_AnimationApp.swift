//
//  Vibe_AnimationApp.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

@main
struct Vibe_AnimationApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
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
