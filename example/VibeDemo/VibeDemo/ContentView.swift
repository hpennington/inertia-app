////
////  ContentView.swift
////  VibeDemo
////
////  Created by Hayden Pennington on 8/9/24.
////
//
//import SwiftUI
import Inertia
//
//struct BarView : View {
//    let value: Double
//    
//    var body: some View {
//        RoundedRectangle(cornerRadius: 2)
//            .fill(Color.accentColor)
//            .frame(width: 16, height: value * 100)
//    }
//}
//
//struct BarChart: View {
//    var body: some View {
//        HStack(alignment: .bottom) {
//            BarView(value: 0.5)
//            BarView(value: 0.75)
//            BarView(value: 0.34)
//            BarView(value: 0.10)
//            BarView(value: 0.12)
//            BarView(value: 0.11)
//            BarView(value: 0.09)
//            BarView(value: 0.89)
//            BarView(value: 0.87)
//            BarView(value: 0.71)
//        }
//        .padding()
//        .background(Color.gray.opacity(0.1))
//        .cornerRadius(8)
//    }
//}
//
//struct ContentView: View {
//    var body: some View {
//        ScrollView {
//            VStack {
//                HStack {
//                    CircleImage()
//                    Spacer()
//                    Text("iPhony")
//                        .font(.largeTitle)
//                }
//                .padding()
//                
//                .padding(.horizontal)
//                Spacer(minLength: 40)
//                ZStack {
//                    Circle()
//                        .stroke(Color.black.opacity(0.5))
//                        .frame(width: 64, height: 64)
//                    Rectangle()
//                        .fill(Color.black.opacity(0.75))
//                        .frame(width: 2, height: 64)
//                        .rotationEffect(Angle(degrees: 30))
//                }
//                .inertia("car")
//                
//                Spacer(minLength: 40)
//                
//                BarChart()
//                Spacer(minLength: 40)
//                Divider()
//                    .padding(.horizontal)
//                
//                Text("App")
//                    .font(.largeTitle)
//                    .fontWeight(.light)
//                
//                Image("landing_image_1")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                Spacer(minLength: 40)
//                Button {
//                    
//                } label: {
//                    Text("Sign up")
//                        .frame(width: 212, height: 48)
//                        .background(Color.black.opacity(0.9))
//                        .foregroundColor(.gray)
//                        .cornerRadius(8)
//                }
//                .buttonStyle(.plain)
//                .inertia("homeCard")
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}

import SwiftUI

struct ContentView: View {
    @State private var showMessage = false

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack {
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
                            .background(Color.blue)
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
                .inertia("card1")
            }
        }
    }
}

#Preview {
    ContentView()
}
