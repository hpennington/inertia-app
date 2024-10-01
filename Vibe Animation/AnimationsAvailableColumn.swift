//
//  AnimationsAvailableColumn.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/30/24.
//

import SwiftUI

struct AnimationsAvailableColumn: View {
    let animations: [String]
    
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
        VStack {
            SearchField(text: $textQuery)
            
            AnimationsList(animations: filteredAnimations)
        }
    }
}

#Preview {
    AnimationsAvailableColumn(animations: [
        "Animation0",
        "Animation1",
    ])
}
