//
//  RenderView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

struct RenderView: View {
    var body: some View {
        ColorPalette.black
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(4)
    }
}

#Preview {
    RenderView()
}
