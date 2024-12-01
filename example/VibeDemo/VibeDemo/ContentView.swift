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
                .inertiaEditable()
            Spacer()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .inertiaEditable()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .inertiaEditable()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .inertiaEditable()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .inertiaEditable()
            
            HStack {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .inertiaEditable()
                Image(systemName: "chevron.up")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .inertiaEditable()
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .inertiaEditable()
            }
            .inertiaEditable()
            
            Button("Start") {
                
            }
            .buttonStyle(.bordered)
            .inertiaEditable()
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .inertiaEditable()
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .inertiaEditable()
    }
}

#Preview {
    ContentView()
}
