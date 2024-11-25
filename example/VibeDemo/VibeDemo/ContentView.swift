//
//  ContentView.swift
//  VibeDemo
//
//  Created by Hayden Pennington on 8/9/24.
//

import SwiftUI
import Inertia

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .vibeHello(hierarchyID: "10")
            
            VStack {
                Text("Hello, world!")
                    .vibeHello(hierarchyID: "1")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
