//
//  FocusIndicator.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 10/13/24.
//

import SwiftUI

struct FocusIndicator: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("Focus", systemImage: "scope", isOn: $isOn)
            .labelStyle(.iconOnly)
            .toggleStyle(.button)
            
    }
}

#Preview {
    @Previewable @State var isOn = false
    FocusIndicator(isOn: $isOn)
}
