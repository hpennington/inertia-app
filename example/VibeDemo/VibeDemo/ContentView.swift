//
//  ContentView.swift
//  VibeDemo
//
//  Created by Hayden Pennington on 8/9/24.
//

import SwiftUI
import Inertia

struct ViewA: View {
    let text: String
    
    var body: some View {
        ViewB(text: text)
    }
}

struct ViewB: View {
    let text: String
    
    var body: some View {
        Text(text)
    }
}


struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 48)
            Text("Hello, world!")

            Spacer()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            
            ForEach(0..<4) { index in
                ViewA(text: "some text \(index)")
            }
            
            HStack {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Image(systemName: "chevron.up")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            }
            Button("Start") {
                
            }
            .buttonStyle(.bordered)
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
