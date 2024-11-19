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
            Group { // Never place VibeContainer as the first elemetn in the WindowGroup or onAppear will fire in different order.
                VibeContainer(id: "animation1", hierarchyID: "4") {
                    ContentView()
                }
            }
        }
    }
}
