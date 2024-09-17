//
//  SetupFlowSwiftUIConfigurationScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/4/24.
//

import SwiftUI

struct SetupFlowSwiftUIConfigurationScreen: View {
    @EnvironmentObject var setupFlowManager: SetupFlowManager
    @FocusState var focusState: FocusableElement?
        
    enum FocusableElement: Hashable {
        case projectURL
        case entryPoint
    }
    
    let action: (SetupFlowEvent) -> Void
    
    var isContinueValid: Bool {
        setupFlowManager.xcodeProjectURL.isEmpty || setupFlowManager.entryStructTitle.isEmpty
    }
    
    var body: some View {
        SetupFlowBase(title: "Setup the SwiftUI Configuration") {
            VStack(spacing: 16) {
                VibeTextField(title: "Xcode Project URL", text: $setupFlowManager.xcodeProjectURL)
                    .focused($focusState, equals: .projectURL)
                    .onSubmit {
                        focusState = .entryPoint
                    }
                VibeTextField(title: "Entry Struct", text: $setupFlowManager.entryStructTitle)
                    .focused($focusState, equals: .entryPoint)
                Spacer(minLength: 0)
            
                SetupActionButton(title: "Continue") {
                    action(.continueSetupSwiftUI)
                }
                .disabled(isContinueValid)
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .task {
            focusState = .projectURL
        }
    }
}

//#Preview {
//    SetupFlowSwiftUIConfigurationScreen()
//}
