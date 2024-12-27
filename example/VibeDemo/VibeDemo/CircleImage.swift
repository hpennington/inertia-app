//
//  CircleImage.swift
//  VibeDemo
//
//  Created by Hayden Pennington on 12/26/24.
//

import SwiftUI

struct CircleImage: View {
    var body: some View {
        Image("landing_image_2", bundle: .main)
            .resizable()
            .frame(width: 64, height: 64)
            .cornerRadius(64)
    }
}

#Preview {
    CircleImage()
}
