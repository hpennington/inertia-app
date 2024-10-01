//
//  SearchField.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/23/24.
//

import SwiftUI

struct SearchField: View {
    @State private var text = ""
    
    private let cornerRadius = 4.0
    private let padding = 8.0
    
    var body: some View {
        TextField("", text: $text)
            .textFieldStyle(.plain)
            .padding(padding)
            .frame(minHeight: cornerRadius * 2)
            .cornerRadius(cornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(ColorPalette.gray1)
            }
    }
}

#Preview {
    SearchField()
}
