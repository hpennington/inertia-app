//
//  SetupFlowBase.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct SetupFlowBase<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: .zero) {
            HStack(spacing: .zero) {
                NavigationBackButton {
                    dismiss()
                }
                .padding(.vertical, 8)
                
                Spacer()
                
                SetupTitleView(title: title)
                
                Spacer()
                NavigationBackButton {
                    
                }
                .padding(.vertical, 8)
                .hidden()
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: .zero) {
                content()
            }
            .frame(maxWidth: 280)
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.gray1)
    }
}

#Preview {
    SetupFlowBase(title: "Testing") {
        
    }
}
