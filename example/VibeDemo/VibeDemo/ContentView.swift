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
                .vibeHello()
            
            VibeContainer(id: "animation2") {
                VStack {
                    Text("Hello, world!")
                        .vibeHello()
                }
                
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
