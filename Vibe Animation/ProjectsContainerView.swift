//
//  ProjectsContainerView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 8/26/24.
//

import SwiftUI

struct ProjectsContainerView<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    private let containerWidth = 775.0
    private let containerHeight = 445.0
    
    var body: some View {
        content()
            .frame(width: containerWidth, height: containerHeight)
    }
}

#Preview {
    ProjectsContainerView {
        Text("ProjectsContainerView")
    }
}
