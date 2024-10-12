//
//  EditorView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI
import WebKit
import Vibe

enum VibeWebScript: String, RawRepresentable {
    case initialize = "init"
    case actionablesAdd = "actionablesAdd"
    case actionablesRemove = "actionablesRemove"
}

enum VibeWebScriptError: Error {
    case didFailToFind
    case didFailToParse
    case didFailToEval(Error)
    case didFailToParseReturnValue
}

@MainActor
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
        case navigate
        case design
        case animate
        
        var id: Self { self }
    }
    
    init(
        url: URL,
        framework: SetupFlowFramework,
        animations: [VibeSchema],
        webView: WKWebView,
        contentController: WKUserContentController,
        configuration: WKWebViewConfiguration
    ) {
        self.url = url
        self.framework = framework
        self.animations = animations
        self.webView = webView
        self.contentController = contentController
        self.configuration = configuration
    }
    
    @State private var appMode: AppMode = .navigate
    @State private var frameSize: CGSize? = nil
    
    let url: URL
    let framework: SetupFlowFramework
    let animations: [VibeSchema]
    let webView: WKWebView
    let contentController: WKUserContentController
    let configuration: WKWebViewConfiguration
    
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
    
    func executeVibeWebScript(script: VibeWebScript) async -> Result<Int, VibeWebScriptError> {
        guard let vibeScriptURL = Bundle.main.url(forResource: script.rawValue, withExtension: "js") else {
            print("failed to load \(script.rawValue).js from Bundle.main")
            return .failure(.didFailToFind)
        }
        
        guard let vibeScriptContents = try? String(contentsOf: vibeScriptURL, encoding: .utf8) else {
            print("Failed to parse file contents of URL: \(vibeScriptURL)")
            return .failure(.didFailToParse)
        }
        
        do {
            guard let returnValue = (try await webView.evaluateJavaScript(vibeScriptContents)) as? Int else {
                return .failure(.didFailToParseReturnValue)
            }
            
            return .success(returnValue)
        } catch let error {
            return .failure(.didFailToEval(error))
        }
    }
    
    private func attachVibeActionables() async {
        let actionablesResult = await executeVibeWebScript(script: .actionablesAdd)
        switch actionablesResult {
        case .success(let success):
            print(success)
        case .failure(let failure):
            print(failure)
        }
    }
    
    private func initializeAndActionablesAdd() async {
        let result = await executeVibeWebScript(script: .initialize)
        switch result {
        case .success(let returnCode):
            print("code: \(returnCode)")
            await attachVibeActionables()
        case .failure(let error):
            print(error)
        }
    }
    
    private func actionablesRemove() async {
        let result = await executeVibeWebScript(script: .actionablesRemove)
        switch result {
        case .success(let returnCode):
            print("code: \(returnCode)")
        case .failure(let error):
            print(error)
        }
    }
    
    private func switchAppMode(newValue: AppMode) async {
        switch (newValue) {
        case .animate:
            await initializeAndActionablesAdd()
        case .design:
            break
        case .navigate:
            await actionablesRemove()
        }
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
                        WebRenderView(
                            url: url,
                            contentController: contentController,
                            webView: webView
                        )
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
                .onChange(of: appMode) { _, newValue in
                    Task {
                        await switchAppMode(newValue: newValue)
                    }
                    
                }
            } trailing: {
                VStack {
                    VStack {
                        Picker(selection: $appMode) {
                            Text("Navigate")
                                .tag(AppMode.navigate)
                            Text("Animate")
                                .tag(AppMode.animate)
                            Text("Design")
                                .tag(AppMode.design)
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
