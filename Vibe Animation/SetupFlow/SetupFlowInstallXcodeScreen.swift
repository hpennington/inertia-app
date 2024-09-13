//
//  SetupFlowInstallXcodeScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/4/24.
//

import SwiftUI

struct SetupFlowInstallXcodeScreen: View {    
    let action: (SetupFlowEvent) -> Void
    
    var body: some View {
        SetupFlowBase(title: "Install Xcode") {
            VStack(spacing: 16) {
                Text("Be sure to install Xcode and the Xcode Command Line Tools before proceeding.")
                    .foregroundStyle(ColorPalette.gray5)
                
                Spacer()
            
                SetupActionButton(title: "Continue") {
                    action(.continueSetup)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
    }
}

//#Preview {
//    SetupFlowInstallXcodeScreen()
//}
