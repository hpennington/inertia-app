//
//  ProjectsContainerSplitView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 8/26/24.
//

import SwiftUI

struct ProjectsContainerSplitView<ContentLeft: View, ContentRight: View>: View {
    @ViewBuilder let contentLeft: () -> ContentLeft
    @ViewBuilder let contentRight: () -> ContentRight
    
    var body: some View {
        HStack(spacing: .zero) {
            contentLeft()
                .background(ColorPalette.gray1)
            contentRight()
        }
    }
}

#Preview {
    ProjectsContainerSplitView {
        
    } contentRight: {
        
    }
}
