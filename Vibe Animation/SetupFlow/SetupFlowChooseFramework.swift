//
//  SetupFlowChooseFramework.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct SetupFlowChooseFramework: View {
    @State private var tag: Tag = reactTag
    @State private var showNext: Bool = false
    
    var body: some View {
        SetupFlowBase(title: "Choose a Framework") {
            VStack(spacing: 16) {
                RadioGroup(selectedTag: $tag) {
                    RadioButton(tag: reactTag) {
                        RadioButtonContent(title: "Web (React)")
                    }
                    RadioButton(tag: swiftUITag) {
                        RadioButtonContent(title: "iOS (SwiftUI)")
                    }
                }
                
                Spacer()
                
                SetupActionButton(title: "Continue") {
                    showNext = true
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .navigationDestination(isPresented: $showNext) {
            SetupFlowInfoScreen()
        }
    }
}

#Preview {
    SetupFlowChooseFramework()
}
