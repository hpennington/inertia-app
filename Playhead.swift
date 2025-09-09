//
//  Playhead.swift
//  Inertia App
//
//  Created by Hayden Pennington on 9/7/25.
//

import SwiftUI

struct Playhead: View {
    let label: String
    
    var body: some View {
        VStack(spacing: .zero) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.accentColor.tertiary)
                .frame(width: 50, height: 25)
                .overlay {
                    Text(label)
                }
            Rectangle()
                .frame(width: 2)
        }
    }
}
