//
//  SetupFlowWebConfigurationScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct SetupFlowWebConfigurationScreen: View {
    @State private var url = ""
    
    var body: some View {
        SetupFlowBase(title: "Configure the web URL") {
            VStack(spacing: 16) {
                VibeTextField(title: "Server URL", text: $url)
                Spacer()
            
                SetupActionButton(title: "Continue", disabled: url.isEmpty) {
                    
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
    }
}

#Preview {
    SetupFlowWebConfigurationScreen()
}
