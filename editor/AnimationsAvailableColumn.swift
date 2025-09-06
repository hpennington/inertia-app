//
//  AnimationsAvailableColumn.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/30/24.
//

import SwiftUI

struct AnimationsAvailableColumn: View {
    let animations: [String: [String]]
    let selected: Binding<String>
    let actionableIds: Set<String>?
    let disabled: Bool
    let actionTitle: String
    let attachAnimation: (_ id: String, _ actionableIds: Set<String>) -> Void
    
    @State private var textQuery = ""
    
//    private func filterAnimations(animations: [String: [String]], query: String) -> [String: [String]] {
//        animations.filter {
//            let animation = animations[$0]
//            $0
//                .lowercased()
//                .trimmingCharacters(in: .whitespacesAndNewlines)
//                .contains(query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
//            ? true : false
//        }
//    }
//    
//    var filteredAnimations: [String] {
//        if textQuery.isEmpty {
//            animations
//        } else {
//            filterAnimations(animations: animations, query: textQuery)
//        }
//    }
    
    var body: some View {
        VStack(alignment: .leading) {
            SearchField(text: $textQuery)
            
            AnimationsList(animations: animations, selected: selected)
            
            AttachAnimationButton(title: actionTitle) {
                if let actionableIds, !selected.wrappedValue.isEmpty {
                    attachAnimation(selected.wrappedValue, actionableIds)
                }
            }
            .padding(.vertical)
            .disabled(selected.wrappedValue.isEmpty || disabled)
        }
    }
}

//#Preview {
//    AnimationsAvailableColumn(animations: [
//        "Animation0",
//        "Animation1",
//    ], selected: .constant(""), actionableIds: Set(), disabled: false) { animationId, actionableIds in
//        
//    }
//}
