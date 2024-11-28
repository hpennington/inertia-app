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
            Spacer()
                .frame(height: 48)
            Text("Hello, world!")
                .vibeHello()
            Spacer()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .vibeHello()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .vibeHello()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .vibeHello()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .vibeHello()
            
            HStack {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .vibeHello()
                Image(systemName: "chevron.up")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .vibeHello()
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .vibeHello()
            }
            .vibeHello()
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .vibeHello()
            Spacer()
        }
        .padding()
        .vibeHello()
    }
}

#Preview {
    ContentView()
}
