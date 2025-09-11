//
//  AttachAnimationButton.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 10/14/24.
//

import SwiftUI

struct AttachAnimationButton: View {
    @Environment(\.appColors) var appColors: Colors
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(title, action: action)
            .background(appColors.accent)
            .foregroundStyle(colorScheme == .dark ? .white : .black)
    }
}

#Preview {
    AttachAnimationButton(title: "Attach") {
        
    }
}
