//
//  AnimationsAttachedList.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/30/24.
//

import SwiftUI

struct AnimationsAttachedList: View {
    let animations: Set<String>
    
    @State private var selected = "anim1"
    
    private let cornerRadius = 4.0
    
    var body: some View {
        List(selection: $selected) {
            Section {
                ForEach(Array(animations), id: \.self) { animation in
                    Text(animation)
                        .tag(animation)
                }
            }
            .listRowSeparator(.hidden)
        }
        .pickerStyle(.inline)
        .scrollContentBackground(.hidden)
        .frame(minHeight: cornerRadius * 2)
        .cornerRadius(cornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(ColorPalette.gray1)
        }
    }
}

#Preview {
    AnimationsAttachedList(animations: [
    ])
}
