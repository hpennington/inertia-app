//
//  SetupFlowInfoScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct SetupFlowInfoScreen: View {
    @State private var title = ""
    @State private var description = ""
    @State private var showNext: Bool = false
    
    var body: some View {
        SetupFlowBase(title: "Give your Project a Name") {
            VStack(spacing: 16) {
                VibeTextField(title: "Title", text: $title)
                VibeTextContainer(title: "Description", text: $description)
                Spacer()
            
                SetupActionButton(title: "Continue", disabled: title.isEmpty) {
                    showNext = true
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .navigationDestination(isPresented: $showNext) {
            SetupFlowWebConfigurationScreen()
        }
    }
}

#Preview {
    SetupFlowInfoScreen()
}
