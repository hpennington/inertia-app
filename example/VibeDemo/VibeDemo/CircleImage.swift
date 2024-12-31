//
//  CircleImage.swift
//  VibeDemo
//
//  Created by Hayden Pennington on 12/26/24.
//

import SwiftUI
import Inertia

struct CircleImage: View {
    var body: some View {
        Image("landing_image_2", bundle: .main)
            .resizable()
            .frame(width: 64, height: 64)
            .cornerRadius(64).inertiaEditable("AAED85FC-056E-40E7-9A92-6BF302D35A09")
    }
}

#Preview {
    CircleImage()
}
