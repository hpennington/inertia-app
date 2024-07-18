//
//  PanelView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

struct PanelView: View {
    @Environment(\.appColors) private var appColors
    
    var body: some View {
        appColors.backgroundPrimary
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PanelView()
}
