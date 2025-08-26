//
//  SetupFlowWebConfigurationScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI
//
//struct SetupFlowWebConfigurationScreen: View {
//    @EnvironmentObject var setupFlowManager: SetupFlowManager
//    @FocusState var focusState: FocusableElement?
//    @State private var error: Bool = false
//    
//    enum FocusableElement: Hashable {
//        case serverURL
//    }
//    
//    let action: (SetupFlowEvent) -> Void
//    
//    var validURL: URL? {
//        setupFlowManager.reactProjectURL
//    }
//    
//    var isInvalidURL: Bool {
//        validURL == nil && !setupFlowManager.reactProjectPath.isEmpty
//    }
//    
//    var body: some View {
//        SetupFlowBase(title: "Configure the web URL") {
//            VStack(spacing: 16) {
//                VibeTextField(title: "Server URL", text: $setupFlowManager.reactProjectPath, error: isInvalidURL)
//                    .focused($focusState, equals: .serverURL)
//                Spacer()
//            
//                SetupActionButton(title: "Continue", disabled: setupFlowManager.reactProjectPath.isEmpty || isInvalidURL) {
//                    if !isInvalidURL {
//                        action(.continueSetupReact)
//                    }
//                }
//            }
//            .padding(.top, 8)
//            .padding(.bottom, 48)
//        }
//        .task {
//            focusState = .serverURL
//        }
//    }
//}

