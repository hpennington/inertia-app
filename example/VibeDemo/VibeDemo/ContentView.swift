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
//            .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB3141")
    }
}


struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 48)
            Text("Hello, world!")
                .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB31B2")
            Spacer()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB31B3")
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB31B4")
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB31B5")
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB31B6")
            
            ForEach(0..<4) { index in
                ViewA(text: "some text \(index)")
                    .inertiaEditable("viewAID")
            }
            
            HStack {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB31B17")
                Image(systemName: "chevron.up")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB31B8")
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB31B9")
            }
            .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB3110")
            Button("Start") {
                
            }
            .buttonStyle(.bordered)
            .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB3111")
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB3112")
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity).inertiaEditable("4FCE84E6-E41E-4FBA-9151-B2C11AAB3113")
    }
}

#Preview {
    ContentView()
}
