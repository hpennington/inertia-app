//
//  SetupFlowSwiftUIConfigurationScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/4/24.
//

import SwiftUI

struct SetupFlowSwiftUIConfigurationScreen: View {
    @EnvironmentObject var setupFlowManager: SetupFlowManager
    
    let action: (SetupFlowEvent) -> Void
    
    var isContinueValid: Bool {
        setupFlowManager.xcodeProjectURL.isEmpty || setupFlowManager.entryStructTitle.isEmpty
    }
    
    var body: some View {
        SetupFlowBase(title: "Setup the SwiftUI Configuration") {
            VStack(spacing: 16) {
                VibeTextField(title: "Xcode Project URL", text: $setupFlowManager.xcodeProjectURL)
                VibeTextField(title: "Entry Struct", text: $setupFlowManager.entryStructTitle)
                Spacer(minLength: 0)
            
                SetupActionButton(title: "Continue") {
                    action(.continueSetup)
                }
                .disabled(isContinueValid)
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
    }
}

//#Preview {
//    SetupFlowSwiftUIConfigurationScreen()
//}
