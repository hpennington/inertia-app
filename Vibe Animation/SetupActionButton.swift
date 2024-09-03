//
//  SetupActionButton.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct SetupActionButton: View {
    let title: String
    let action: () -> Void
    let accentColor: Color = ColorPalette.purple0
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .frame(width: 280, height: 44)
                .background(accentColor)
                .foregroundColor(ColorPalette.white)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SetupActionButton(title: "Testing") {
        print("Testing tapped")
    }
}
