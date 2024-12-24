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
        ViewB(text: text).inertiaEditable("98BC6E3B-2C0C-4ABB-8C39-1BED3AB21C9A")
    }
}

struct ViewB: View {
    let text: String
    
    var body: some View {
        Text(text).inertiaEditable("AE94D98A-B5C7-4B8B-A2C2-D9B552D8210F")
    }
}


struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 48).inertiaEditable("79997648-C3E2-4B74-B85B-2878C51FD8E1")
            Text("Hello, world!").inertiaEditable("33653435-97DE-42EB-992E-E1BB80EAFA5E")

            Spacer().inertiaEditable("0105D9C0-2156-49EB-9A3D-95A8B8876348")
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint).inertiaEditable("9B36D3E2-5C71-4138-8AD1-E40A3F84EAC8")

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint).inertiaEditable("E4F6D549-8CE4-4A84-9306-EE6E03E7D46C")

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint).inertiaEditable("EE6325EE-DC22-4555-9CBA-2383CC39EC3F")

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint).inertiaEditable("E7771D03-5E95-469B-89ED-5DFED9E52641")

            
            VStack {
                ForEach(0..<4) { index in
                    ViewA(text: "some text \(index)").inertiaEditable("9856E550-076D-49C1-B8F6-2E579D87C2B5")
                }
            }.inertiaEditable("0C83F219-AAE9-4131-8A2E-ABEA9377D3C4")
            
            HStack {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundStyle(.tint).inertiaEditable("0EEB4B8C-D21F-4F62-946F-2966488B640B")
                Image(systemName: "chevron.up")
                    .imageScale(.large)
                    .foregroundStyle(.tint).inertiaEditable("A9D6ACAF-795E-4852-83DF-02C2FCD63341")
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .foregroundStyle(.tint).inertiaEditable("14886F75-1FBE-45F9-92AB-91C2CEA6ACAB")
            }.inertiaEditable("12AF249D-138D-4F38-BBDC-9261EE5043B3")
            Button("Start") {
                
            }
            .buttonStyle(.bordered).inertiaEditable("F85ACED4-9AC1-41B5-B1A5-A9BD5554CED1")
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint).inertiaEditable("0DC76DBC-A014-4653-A3B7-8CADDA288F89")
            Spacer().inertiaEditable("DCD1E386-5390-4D8E-9B51-1C2F907E1FE0")
        }.inertiaEditable("3B024941-0B31-4FA5-8457-FD044DC35085")
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity).inertiaEditable("E21AFA7E-A2C1-4E67-8F3B-E97D4BC25B89")
    }
}

#Preview {
    ContentView()
}
