//
//  NavigationBackButton.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct NavigationBackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.backward")
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 18)
                .foregroundStyle(ColorPalette.gray3)
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
    }
}

#Preview {
    NavigationBackButton {
        
    }
}
