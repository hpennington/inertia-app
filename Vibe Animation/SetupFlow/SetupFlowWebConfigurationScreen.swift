//
//  SetupFlowWebConfigurationScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct SetupFlowWebConfigurationScreen: View {
    @EnvironmentObject var setupFlowManager: SetupFlowManager
    
    let action: (SetupFlowEvent) -> Void
    
    var body: some View {
        SetupFlowBase(title: "Configure the web URL") {
            VStack(spacing: 16) {
                VibeTextField(title: "Server URL", text: $setupFlowManager.reactProjectURL)
                Spacer()
            
                SetupActionButton(title: "Continue", disabled: setupFlowManager.reactProjectURL.isEmpty) {
                    action(.continueSetup)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
    }
}

