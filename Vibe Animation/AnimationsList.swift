//
//  AnimationsList.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/30/24.
//

import SwiftUI

struct AnimationsList: View {
    let animations: [String: [String]]
    let selected: Binding<String>
    
    private let cornerRadius = 4.0
    
    class Tree<Value: Hashable>: Hashable {
        let value: Value
        var children: [Tree]? = nil
        weak var parent: Tree? = nil
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(value)
        }
        
        public static func ==(lhs: Tree, rhs: Tree) -> Bool {
            lhs.value == rhs.value
        }
        
        init(value: Value, children: [Tree]? = nil, parent: Tree? = nil) {
            self.value = value
            self.children = children
            self.parent = parent
        }
    }
    
    var categories: [Tree<String>] {
        animations.keys.sorted().compactMap {
            if let children = animations[$0] {
                return .init(value: $0, children: children.map({ childTitle in
                    .init(value: childTitle)
                }))
            }
            
            return nil
        }
    }
    
    var body: some View {
        List(categories, id: \.value, children: \.children, selection: selected) { tree in
            Text(tree.value)
                .tag(tree.value)
        }
        .listStyle(SidebarListStyle())
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

//#Preview {
//    AnimationsList(animations: [
//        "anim1",
//        "anim2",
//        "anim3",
//        "anim4",
//        "anim5"
//    ], selected: .constant("anim1"))
//}
