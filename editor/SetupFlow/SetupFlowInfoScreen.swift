//
//  SetupFlowInfoScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct SetupFlowInfoScreenReact: View {
    @EnvironmentObject var setupFlowManager: SetupFlowManager
    @FocusState var focusState: FocusableElement?
        
    enum FocusableElement: Hashable {
        case titleTextField
        case descriptionTextField
    }
    
    let action: (SetupFlowEvent) -> Void
    
    var body: some View {
        SetupFlowBase(title: "Give your Project a Name") {
            VStack(spacing: 16) {
                VibeTextField(title: "Title", text: $setupFlowManager.projectTitle)
                    .focused($focusState, equals: .titleTextField)
                    .onSubmit {
                        focusState = .descriptionTextField
                    }
                
                VibeTextContainer(title: "Description", text: $setupFlowManager.projectDescription)
                    .focused($focusState, equals: .descriptionTextField)
                Spacer()
            
                SetupActionButton(title: "Continue", disabled: setupFlowManager.projectTitle.isEmpty) {
                    action(.continueSetupReact)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .onAppear {
            focusState = .titleTextField
        }
    }
}

struct SetupFlowInfoScreenCompose: View {
    @EnvironmentObject var setupFlowManager: SetupFlowManager
    @State private var description = ""
    @FocusState var focusState: FocusableElement?
        
    enum FocusableElement: Hashable {
        case titleTextField
        case descriptionTextField
    }
    
    let action: (SetupFlowEvent) -> Void
    
    var body: some View {
        SetupFlowBase(title: "Give your Project a Name") {
            VStack(spacing: 16) {
                VibeTextField(title: "Title", text: $setupFlowManager.projectTitle)
                    .focused($focusState, equals: .titleTextField)
                    .onSubmit {
                        focusState = .descriptionTextField
                    }
                VibeTextContainer(title: "Description", text: $description)
                    .focused($focusState, equals: .descriptionTextField)
                Spacer()
            
                SetupActionButton(title: "Continue", disabled: setupFlowManager.projectTitle.isEmpty) {
                    action(.continueSetupCompose)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .task {
            focusState = .titleTextField
        }
    }
}

struct SetupFlowInfoScreenSwiftUI: View {
    @EnvironmentObject var setupFlowManager: SetupFlowManager
    @State private var description = ""
    @FocusState var focusState: FocusableElement?
        
    enum FocusableElement: Hashable {
        case titleTextField
        case descriptionTextField
    }
    
    let action: (SetupFlowEvent) -> Void
    
    var body: some View {
        SetupFlowBase(title: "Give your Project a Name") {
            VStack(spacing: 16) {
                VibeTextField(title: "Title", text: $setupFlowManager.projectTitle)
                    .focused($focusState, equals: .titleTextField)
                    .onSubmit {
                        focusState = .descriptionTextField
                    }
                VibeTextContainer(title: "Description", text: $description)
                    .focused($focusState, equals: .descriptionTextField)
                Spacer()
            
                SetupActionButton(title: "Continue", disabled: setupFlowManager.projectTitle.isEmpty) {
                    action(.continueSetupSwiftUI)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .task {
            focusState = .titleTextField
        }
    }
}

//#Preview {
//    SetupFlowInfoScreen()
//}
