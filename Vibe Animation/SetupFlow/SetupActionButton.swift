//
//  SetupActionButton.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct SetupActionButton: View {
    let title: String
    let disabled: Bool
    let accentColor: Color
    let action: () -> Void
    
    init(title: String, disabled: Bool = false, accentColor: Color = ColorPalette.accentTheme, action: @escaping () -> Void) {
        self.title = title
        self.disabled = disabled
        self.accentColor = accentColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .frame(width: 280, height: 40)
                .background(accentColor)
                .foregroundColor(ColorPalette.white)
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}

#Preview {
    SetupActionButton(title: "Testing") {
        print("Testing tapped")
    }
}
