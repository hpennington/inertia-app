//
//  AnimationsAvailableColumn.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/30/24.
//

import SwiftUI

struct AnimationsAvailableColumn: View {
    let animations: [String]
    
    var body: some View {
        VStack {
            SearchField()
            
            AnimationsList(animations: animations)
        }
    }
}

#Preview {
    AnimationsAvailableColumn(animations: [
        "Animation0",
        "Animation1",
    ])
}
