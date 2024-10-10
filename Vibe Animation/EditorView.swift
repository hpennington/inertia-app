//
//  EditorView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI
import Vibe

struct EditorView: View {
    @Environment(\.colorScheme) var colorScheme
    @FocusState var focusState: FocusableElement?
        
    enum FocusableElement: Hashable {
        case viewport
    }
    
    private let hierarchyViewWidth: CGFloat = 300
    private let viewportMinimumSize = CGSize(width: 650, height: 350)
    private let propertiesViewWidth: CGFloat = 300
    private let timelineViewHeight: CGFloat = 200
    private let renderViewportCornerRadius: CGFloat = 4
    private let segmentedPickerWidth: CGFloat = 250
    private let spacing: CGFloat = 3
    private let cornerRadius: CGFloat = 4
    
    enum AppMode: Identifiable  {
        case design
        case animate
        
        var id: Self { self }
    }
    
    @State private var appMode: AppMode = .design
    @State private var frameSize: CGSize? = nil
    
    let url: URL
    let framework: SetupFlowFramework
    let animations: [VibeSchema]
    
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
    
    func maxCGSize(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
    }
    
    var body: some View {
        VStack {
            MainLayout {
                PanelView()
                    .frame(width: hierarchyViewWidth)
            } content: {
                Group {
                    switch framework {
                    case .react:
                        WebRenderView(url: url)
                    case .swiftUI:
                        GeometryReader { proxy in
                            MacRenderView(size: viewportMinimumSize)
                                .onAppear {
                                    frameSize = maxCGSize(lhs: proxy.size, rhs: viewportMinimumSize)
                                }
                                .onChange(of: proxy.size) { oldValue, newValue in
                                    frameSize = maxCGSize(lhs: newValue, rhs: viewportMinimumSize)
                                }
                        }
                    }
                }
                .cornerRadius(renderViewportCornerRadius)
                .padding()
                .modifier(WithPanelBackground())
                .frame(minWidth: frameSize?.width ?? viewportMinimumSize.width, minHeight: frameSize?.height ?? viewportMinimumSize.height)
                .focused($focusState, equals: .viewport)
                .onAppear {
                    focusState = .viewport
                }
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
                        .padding()

                        AnimationsAvailableColumn(animations: animations.map {
                            $0.id
                        })
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    .modifier(WithPanelBackground())
                    .cornerRadius(bottomLeft: cornerRadius)
                    
                    Spacer(minLength: spacing)
                    
                    VStack {
                        AnimationsAttachedList(animations: animations.map {
                            $0.id
                        })
                        .padding(.vertical)
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
                    .modifier(WithPanelBackground())
                    .cornerRadius(topLeft: cornerRadius)
                }
                .frame(maxWidth: propertiesViewWidth, maxHeight: .infinity)
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
