//
//  VibeTextContainer.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct VibeTextContainer: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title3)
                .foregroundStyle(ColorPalette.gray5)
            TextEditor(text: $text)
                .textEditorStyle(.plain)
                .font(.title3)
                .foregroundStyle(ColorPalette.gray5)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(ColorPalette.gray4.opacity(0.5))
                .cornerRadius(4)
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    VibeTextContainer(title: "Title", text: $text)
}
