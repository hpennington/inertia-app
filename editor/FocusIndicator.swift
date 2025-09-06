//
//  FocusIndicator.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 10/13/24.
//

import SwiftUI

struct FocusIndicator: View {
    @Environment(\.appColors) var appColors
    
    @Binding var isOn: Bool

    var body: some View {
        Toggle("Focus", systemImage: "scope", isOn: $isOn)
            .font(.title2)
            .labelStyle(.iconOnly)
            .toggleStyle(.button)
            .buttonStyle(.plain)
            .background(isOn ? appColors.accent : .clear)
            .cornerRadius(4)
            .overlay {
                if !isOn {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(.gray)
                }
            }
    }
}
