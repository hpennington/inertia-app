//
//  ContentView.swift
//  InertiaDemo
//
//  Created by Hayden Pennington on 8/9/24.
//

import Inertia
import SwiftUI

struct Card: View {
    @State private var showMessage = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Welcome")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This is a demo app.")
                .foregroundColor(.gray)

            Button(action: {
                showMessage = true
            }) {
                Text("Press Me")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.orange)
                    .cornerRadius(10)
            }

            if showMessage {
                Text("Button pressed!")
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
            }
        }
        .padding()
        .frame(width: 300)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                    Card()
                        .inertia("card0")
                    
                    Card()
                        .inertia("card1")
                    
                    Card()
                        .inertia("card2")
                    Spacer()
                }
                .padding()
            }
            .padding(EdgeInsets())
        }
    }
}

#Preview {
    ContentView()
}
