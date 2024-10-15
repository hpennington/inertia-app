//
//  AnimationsAvailableColumn.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/30/24.
//

import SwiftUI

struct AnimationsAvailableColumn: View {
    let animations: [String]
    let selected: Binding<String>
    let actionableIds: Set<String>
    let disabled: Bool
    let attachAnimation: (_ animationId: String, _ actionableIds: Set<String>) -> Void
    
    @State private var textQuery = ""
    
    private func filterAnimations(animations: [String], query: String) -> [String] {
        animations.compactMap {
            $0
                .lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .contains(query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
            ? $0 : nil
        }
    }
    
    var filteredAnimations: [String] {
        if textQuery.isEmpty {
            animations
        } else {
            filterAnimations(animations: animations, query: textQuery)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            SearchField(text: $textQuery)
            
            AnimationsList(animations: filteredAnimations, selected: selected)
            
            AttachAnimationButton {
                if !selected.wrappedValue.isEmpty {
                    attachAnimation(selected.wrappedValue, actionableIds)
                }
            }
            .padding(.vertical)
            .disabled(selected.wrappedValue.isEmpty || disabled)
        }
    }
}

#Preview {
    AnimationsAvailableColumn(animations: [
        "Animation0",
        "Animation1",
    ], selected: .constant(""), actionableIds: Set(), disabled: false) { animationId, actionableIds in
        
    }
}
