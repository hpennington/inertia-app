//
//  InertiaDemoApp.swift
//  InertiaDemo
//
//  Created by Hayden Pennington on 8/9/24.
//

import SwiftUI
import Inertia

struct AppEnvironment {
    #if INERTIA_EDITOR
    static let isInertiaEditor = true
    #else
    static let isInertiaEditor = false
    #endif
}

@main
struct InertiaDemoApp: App {
    var body: some Scene {
        WindowGroup {
            InertiaContainer(
                dev: AppEnvironment.isInertiaEditor,
                id: "animation",
                hierarchyId: "animation2"
            ) {
                ContentView()
            }
        }
    }
}
