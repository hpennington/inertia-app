//
//  KeypointIndicator.swift
//  Inertia Pro
//
//  Created by Hayden Pennington on 12/26/24.
//

import SwiftUI

struct TimelineKeypointIndicator: View {
    @Environment(\.appColors) var appColors
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(appColors.accent)
            .frame(width: 16)
            .padding(.vertical, 2)
            .frame(maxHeight: .infinity)
    }
}
