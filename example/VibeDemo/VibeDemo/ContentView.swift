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
                
                VStack {
                    Text("Item 1")
                    Text("Item 2")
                    Text("Item 3")
                    Text("Item 4")
                    Text("Item 5")
                    Text("Item 6")
                    Text("Item 7")
                    Text("Item 8")
                }
            }
            .vibeHello(hierarchyID: "19")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
