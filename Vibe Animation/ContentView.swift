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
    private let renderViewMinimumWidth: CGFloat = 850
    private let renderViewMinimumHieght: CGFloat = 650
    private let propertiesViewWidth: CGFloat = 300
    private let timelineViewHeight: CGFloat = 300
    private let renderViewportCornerRadius: CGFloat = 8
    private let segmentedPickerWidth: CGFloat = 250
    private let spacing: CGFloat = 3
    private let cornerRadius: CGFloat = 4
    
    enum AppMode: Identifiable  {
        case design
        case animate
        
        var id: Self { self }
    }
    
    @State private var appMode: AppMode = .design
    
    var appColors: Colors {
        colorScheme == .dark ? ColorsDark() : ColorsLight()
    }
    
    struct WithPanelBackground: ViewModifier {
        func body(content: Content) -> some View {
            ZStack {
                PanelView()
                content
            }
        }
    }
    
    var body: some View {
        VStack {
            MainLayout {
                PanelView()
                    .frame(width: hierarchyViewWidth)
            } content: {
//                WebRenderView()
                MacRenderView(size: CGSize(width: renderViewportViewWidth, height: renderViewportViewHeight))
                    .frame(width: renderViewportViewWidth, height: renderViewportViewHeight)
                    .cornerRadius(renderViewportCornerRadius)
                    .modifier(WithPanelBackground())
                    .frame(minWidth: renderViewMinimumWidth, minHeight: renderViewMinimumHieght)
            } trailing: {
                VStack {
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
                    .modifier(WithPanelBackground())
                    .cornerRadius(bottomLeft: cornerRadius)
                    
                    Spacer(minLength: spacing)
                    
                    VStack {
                        Text("Testing")
                    }
                    .frame(width: segmentedPickerWidth)
                    .frame(maxHeight: .infinity)
                    .modifier(WithPanelBackground())
                    .cornerRadius(topLeft: cornerRadius, bottomLeft: cornerRadius)
                    
                    Spacer(minLength: spacing)
                    
                    VStack {
                        Text("Testing")
                    }
                    .frame(width: segmentedPickerWidth)
                    .frame(maxHeight: .infinity)
                    .modifier(WithPanelBackground())
                    .cornerRadius(topLeft: cornerRadius)
                }
                .frame(width: propertiesViewWidth)
                .frame(maxHeight: .infinity)
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
