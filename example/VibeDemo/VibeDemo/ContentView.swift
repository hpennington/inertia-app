//
//  ContentView.swift
//  VibeDemo
//
//  Created by Hayden Pennington on 8/9/24.
//

import SwiftUI
import Vibe

struct ContentView: View {
    var body: some View {
        VStack {
            Vibeable {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            }
            
            Vibeable {
                VibeContainer(id: "321123") {
                    VStack {
                        Vibeable {
                            Text("Hello, world!")
                        }
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
