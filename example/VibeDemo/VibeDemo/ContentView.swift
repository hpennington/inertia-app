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
                .vibeHello(hierarchyID: "8")
            
            VStack {
                Text("Hello, world!")
                    .vibeHello(hierarchyID: "1")
                
                Text("Hello, jerry!")
                    .vibeHello(hierarchyID: "Jerry")
                
                List {
                    Text("Item 1")
                        .vibeHello(hierarchyID: "24")
                    Text("Item 2")
                        .vibeHello(hierarchyID: "25")
                }
                .vibeHello(hierarchyID: "23")
            }
            .vibeHello(hierarchyID: "19")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
