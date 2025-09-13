//
//  PanelView.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

struct PanelView: View {
    @Environment(\.appColors) private var appColors
    
    let color: Color?
    
    init(color: Color? = nil) {
        self.color = color
    }
    
    var body: some View {
        (color ?? appColors.backgroundPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PanelView()
}
