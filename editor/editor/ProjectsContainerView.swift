//
//  ProjectsContainerView.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 8/26/24.
//

import SwiftUI

struct ProjectsContainerView<Content: View>: View {
    let width: CGFloat
    let height: CGFloat
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
            .frame(width: width, height: height)
    }
}
