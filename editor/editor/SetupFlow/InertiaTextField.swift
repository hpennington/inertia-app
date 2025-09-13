//
//  InertiaTextField.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct InertiaTextField: View {
    let title: String
    @Binding var text: String
    let error: Bool
    
    init(title: String, text: Binding<String>, error: Bool = false) {
        self.title = title
        self._text = text
        self.error = error
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title3)
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
                .overlay {
                    if error {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(ColorPalette.red0, lineWidth: 2)
                    }
                }
        }
    }
}

#Preview {
    InertiaTextField(title: "Test Title", text: .constant("Testing text"))
}
