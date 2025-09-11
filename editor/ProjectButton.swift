//
//  NewProjectButton.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 8/26/24.
//

import SwiftUI

struct ProjectButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(ColorPalette.gray2.opacity(0.5))
                
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .foregroundStyle(ColorPalette.gray5)
            }
            .frame(width: 250, height: 40)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProjectButton(title: "New Project") {
        
    }
}
