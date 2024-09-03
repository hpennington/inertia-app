//
//  LaunchLogo.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 8/26/24.
//

import SwiftUI

struct LaunchLogo: View {
    let accentColor: Color
    private let diameter: CGFloat = 72
    
    var body: some View {
        Circle()
            .fill(accentColor)
            .frame(width: diameter, height: diameter)
            .padding()
    }
}

#Preview {
    LaunchLogo(accentColor: .blue)
}
