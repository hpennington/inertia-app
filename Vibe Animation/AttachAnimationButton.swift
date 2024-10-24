//
//  AttachAnimationButton.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 10/14/24.
//

import SwiftUI

struct AttachAnimationButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(title, action: action)
            .background(ColorsDark().accent)
            .foregroundStyle(.white)
    }
}

#Preview {
    AttachAnimationButton(title: "Attach") {
        
    }
}
