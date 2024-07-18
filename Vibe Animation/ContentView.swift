//
//  ContentView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

struct ContentView: View {
    private let hierarchyViewWidth: CGFloat = 300
    private let renderViewportViewWidth: CGFloat = 300
    private let renderViewportViewHieght: CGFloat = 550
    private let renderViewWidth: CGFloat = 650
    private let renderViewHieght: CGFloat = 650
    private let propertiesViewWidth: CGFloat = 300
    private let timelineViewHeight: CGFloat = 300
    private let renderViewportCornerRadius: CGFloat = 24
    
    var body: some View {
        VStack {
            MainLayout {
                PanelView()
                    .frame(width: hierarchyViewWidth)
            } content: {
                ZStack {
                    PanelView()
                        
                    RenderView()
                        .frame(width: renderViewportViewWidth, height: renderViewportViewHieght)
                        .cornerRadius(renderViewportCornerRadius)
                }
                .frame(minWidth: renderViewWidth, minHeight: renderViewHieght)
                
            } trailing: {
                PanelView()
                    .frame(width: propertiesViewWidth)
            } bottom: {
                PanelView()
                    .frame(height: timelineViewHeight)
            }
        }
    }
}

#Preview {
    ContentView()
}
