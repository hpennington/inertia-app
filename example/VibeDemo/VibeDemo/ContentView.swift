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
                .frame(height: 48).inertiaEditable("04E8857F-B825-4916-9489-DF9A829DFA8A")
            Text("Hello, world!").inertiaEditable("25578F7B-C07D-4B78-B508-6BA59996531A")

            Spacer().inertiaEditable("E0B44AE9-E8CE-4A35-B8BB-F2BF6DAE11D8")
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint).inertiaEditable("8AC0254B-29CA-461A-B814-9D4369E09B98")

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint).inertiaEditable("8525882E-7145-499F-8AE5-E3CBC6DFC293")

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint).inertiaEditable("FFE776E9-159F-4440-A642-D567E6390FF0")

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint).inertiaEditable("F6CE6110-70D0-4FF0-A069-6FD0106E393E")

            
            ForEach(0..<4) { index in
                ViewA(text: "some text \(index)").inertiaEditable("7947803A-F46F-4F03-8DD4-F87452A3E1E5")
            }.inertiaEditable("A28FF4EA-CE5A-42B3-B930-D958335B385A")
            
            HStack {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundStyle(.tint).inertiaEditable("6F94CA9A-2354-4CFA-9DD8-F38730368DA2")
                Image(systemName: "chevron.up")
                    .imageScale(.large)
                    .foregroundStyle(.tint).inertiaEditable("7D0DD452-CC25-48FC-BB34-40B6E3F5125D")
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .foregroundStyle(.tint).inertiaEditable("53D41E58-43EC-4194-9DA8-61A41B7BF032")
            }.inertiaEditable("0724A799-2428-4B7A-819A-1FF67387CEF4")
            Button("Start") {
                
            }
            .buttonStyle(.bordered).inertiaEditable("28DFD4D9-F8BF-4421-9AF3-A12FBC08D07F")
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint).inertiaEditable("048348A7-9991-4D70-B3B7-B76F4EDBF660")
            Spacer().inertiaEditable("4E342029-3EA4-426D-8927-CE623287553D")
        }.inertiaEditable("C35AFA2D-6EB2-4427-97B5-4EC68903C871")
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
