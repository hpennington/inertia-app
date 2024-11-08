//
//  AddressBar.swift
//  Inertia Pro
//
//  Created by Hayden Pennington on 11/5/24.
//

import SwiftUI

struct AddressBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appColors) var appColors
    let path: String
    let submit: (String) -> Void
    
    @State private var text: String = ""
    
    var body: some View {
        TextField("Address", text: $text)
            .textFieldStyle(.plain)
            .foregroundStyle(appColors.accent)
            .padding(8)
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(colorScheme == .light ? ColorPalette.gray5 : ColorPalette.gray1, lineWidth: 1)
            }
            .onAppear {
                text = path
            }
            .onSubmit {
                submit(text)
            }
        }
}
