//
//  SetupTitleView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct SetupTitleView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.largeTitle)
            .foregroundStyle(ColorPalette.gray5)
    }
}

#Preview {
    SetupTitleView(title: "Testing")
}
