//
//  VibeDemoApp.swift
//  VibeDemo
//
//  Created by Hayden Pennington on 8/9/24.
//

import SwiftUI
import Vibe

@main
struct VibeDemoApp: App {
    var body: some Scene {
        WindowGroup {
            VibeContainer(id: "1234") {
                ContentView()
            }
        }
    }
}
