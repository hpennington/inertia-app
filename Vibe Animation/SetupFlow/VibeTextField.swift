//
//  VibeTextField.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct VibeTextField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundStyle(ColorPalette.gray5)
            TextField("", text: $text)
                .font(.title3)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .frame(minHeight: 32)
                .background(ColorPalette.gray4.opacity(0.5))
                .foregroundStyle(ColorPalette.gray5)
                .cornerRadius(4)
        }
    }
}

#Preview {
    VibeTextField(title: "Test Title", text: .constant("Testing text"))
}
