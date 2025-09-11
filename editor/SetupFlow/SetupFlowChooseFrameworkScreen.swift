//
//  SetupFlowChooseFrameworkScreen.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct SetupFlowChooseFrameworkScreen: View {
    @EnvironmentObject var setupFlowManager: SetupFlowManager
    
    let action: (SetupFlowEvent) -> Void
    
    var body: some View {
        SetupFlowBase(title: "Choose a Framework") {
            VStack(spacing: 16) {
                RadioGroup(selectedTag: $setupFlowManager.framework) {
                    RadioButton(tag: reactTag) {
                        RadioButtonContent(title: "Web (React)")
                    }
                    RadioButton(tag: swiftUITag) {
                        RadioButtonContent(title: "iOS (SwiftUI)")
                    }
                    RadioButton(tag: jetpackComposeTag) {
                        RadioButtonContent(title: "Android (Compose)")
                    }

                }
                
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
