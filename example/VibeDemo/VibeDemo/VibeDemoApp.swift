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
            VibeContainer(id: "animation1", hierarchyID: "animation1") {
                HStack {
                    ContentView()
                        .vibeHello()
                }
            }
        }
    }
}
