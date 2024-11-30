//
//  VibeDemoApp.swift
//  VibeDemo
//
//  Created by Hayden Pennington on 8/9/24.
//

import SwiftUI
import Inertia

@main
struct VibeDemoApp: App {
    var body: some Scene {
        WindowGroup {
            InertiaContainer(id: "animation1", hierarchyId: "animation1") {
                HStack {
                    ContentView()
                        .inertiaEditable()
                }
            }
        }
    }
}
