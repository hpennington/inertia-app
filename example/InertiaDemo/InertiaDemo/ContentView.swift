//
//  ContentView.swift
//  InertiaDemo
//
//  Created by Hayden Pennington on 8/9/24.
//

import Inertia
import SwiftUI

struct Card: View {
    @State private var isChecked = false
    var cardColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Welcome")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("This is a demo app.")
                .foregroundColor(.gray)
                .font(.subheadline)

            Toggle("Check Me", isOn: $isChecked)
                .toggleStyle(.switch) // macOS-style checkbox
                .padding(.top, 4)

            if isChecked {
                Text("Checked!")
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .frame(width: 300) // shorter card
        .background(cardColor)
        .cornerRadius(16)
        .shadow(radius: 4)
        .onTapGesture {
            isChecked.toggle()
        }
    }
}

struct ContentView: View {
    @Environment(\.inertiaDataModel) private var inertiaDM: InertiaDataModel!
    
    @State private var cardColor: Color = .white
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header with image and text in a row
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .foregroundColor(.blue)
                        
                        Text("Inertia Demo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    Card(cardColor: cardColor)
                        .inertia("card0")
                    
                    Card(cardColor: cardColor)
                        .inertia("card1")
                    
                    Spacer()
                    
                    Button(action: {
                        inertiaDM.trigger("card0")
                    }, label: {
                        Text("Trigger")
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.orange)
                            .cornerRadius(10)
                    })
                    
                    // Button to change card color
                    Button(action: {
                        // Cycle through some colors
                        let colors: [Color] = [.white, .yellow.opacity(0.3), .blue.opacity(0.3), .green.opacity(0.3)]
                        if let index = colors.firstIndex(of: cardColor) {
                            cardColor = colors[(index + 1) % colors.count]
                        } else {
                            cardColor = colors.first!
                        }
                    }) {
                        Text("Change Card Color")
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 40)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
