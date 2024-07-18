//
//  ContentView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let hierarchyViewWidth: CGFloat = 300
    private let renderViewportViewWidth: CGFloat = 750
    private let renderViewportViewHeight: CGFloat = 550
    private let renderViewWidth: CGFloat = 650
    private let renderViewHieght: CGFloat = 650
    private let propertiesViewWidth: CGFloat = 300
    private let timelineViewHeight: CGFloat = 300
    private let renderViewportCornerRadius: CGFloat = 24
    private let segmentedPickerWidth: CGFloat = 250
    
    enum AppMode: Identifiable  {
        case design
        case animate
        
        var id: Self { self }
    }
    
    @State private var appMode: AppMode = .design
    
    var appColors: Colors {
        colorScheme == .dark ? ColorsDark() : ColorsLight()
    }
    
    var body: some View {
        VStack {
            MainLayout {
                PanelView()
                    .frame(width: hierarchyViewWidth)
            } content: {
                ZStack {
                    PanelView()
                    
                    RenderView()
                        .frame(width: renderViewportViewWidth, height: renderViewportViewHeight)
                        .cornerRadius(renderViewportCornerRadius)
                }
                .frame(minWidth: renderViewWidth, minHeight: renderViewHieght)
            } trailing: {
                ZStack {
                    PanelView()
                    
                    VStack {
                        Picker(selection: $appMode) {
                            Text("Design")
                                .tag(AppMode.design)
                            Text("Animate")
                                .tag(AppMode.animate)
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.segmented)
                        .frame(width: segmentedPickerWidth)
                        .padding()
                        
                        Spacer(minLength: .zero)
                    }
                   
                }
                .frame(width: propertiesViewWidth)
            } bottom: {
                PanelView()
                    .frame(height: timelineViewHeight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appColors.backgroundSecondary)
        .environment(\.appColors, appColors)
    }
}

#Preview {
    ContentView()
}
