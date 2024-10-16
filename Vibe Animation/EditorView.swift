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
    case initInvokePlayback = "initInvokePlayback"
    case actionablesAdd = "actionablesAdd"
    case actionablesRemove = "actionablesRemove"
    case animationsAdd = "animationsAdd"
    case animationsRemove = "animationsRemove"
}

enum VibeWebScriptError: Error {
    case didFailToFind
    case didFailToParse
    case didFailToEval(Error)
    case didFailToParseReturnValue
}


@Observable
final class SelectedActionableIDTracker {
    var selectedActionableIds: Set<String> = []
}

@Observable
final class EditorModel {
    var animations: [String: Set<String>] = [:]
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
    
    @State private var appMode: AppMode = .animate
    @State private var editorModel = EditorModel()
    @State private var isFocused = false
    @State private var frameSize: CGSize? = nil
    @State private var selectedActionabeIDTracker = SelectedActionableIDTracker()
    @State private var selectedAnimation: String = ""
    
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
    
    func executeVibeWebFunction(function: String, args: [String]) async -> Result<Int, VibeWebScriptError> {
        do {
            guard let returnValue = (try await webView.evaluateJavaScript("\(function)(\(args))")) as? Int else {
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
    
    private func cleanAnimations() async -> Bool {
        let result = await executeVibeWebScript(script: .animationsRemove)
        switch result {
        case .success(let success):
            return success == 1
        case .failure(let failure):
            print(failure)
            return false
        }
    }
    
    private func injectAnimations() async -> Bool {
        let result = await executeVibeWebScript(script: .animationsAdd)
        
        switch result {
        case .success(let success):
            return success == 1
        case .failure(let failure):
            print(failure)
            return false
        }
    }
    
    struct Animation: Codable, Hashable {
        let actionableId: String
        let animationId: String
    }
    
    struct VibeSchemaWrapper: Codable {
        let schema: String
        let actionableId: String
    }
    
    private func runInvokePlayback() async -> Bool {
        let relavantAnimations = Set(editorModel.animations.map({element in
            let animationId = element.key
            let actionableIds: [String] = element.value.sorted()
            return actionableIds.map {
                Animation(actionableId: $0, animationId: animationId)
            }
        })
        .flatMap({$0}))
        
        let args = relavantAnimations.compactMap { (element: EditorView.Animation) -> String? in
            guard let schema = self.animations.first(where: {element.animationId == $0.id}) else {
                return nil
            }
            guard let schemaText = String(data: (try! JSONEncoder().encode(schema)), encoding: .utf8) else {
                return nil
            }

            let updateSchema = VibeSchemaWrapper(schema: schemaText, actionableId: element.actionableId)
            
            guard let data = try? JSONEncoder().encode(updateSchema) else {
                return nil
            }
            
            return String(data: data, encoding: .utf8)
        }
        
        
        let result = await executeVibeWebFunction(function: "invokePlayback", args: args)
        
        switch result {
        case .success(let success):
            return success == 1
        case .failure(let failure):
            print(failure)
            return false
        }
    }
    
    private func invokePlayback() async -> Bool {
        print(await injectAnimations())
        let result = await executeVibeWebScript(script: .initInvokePlayback)
        
        switch result {
        case .success(let success):
            if success == 1 {
                let playbackSuccess = await runInvokePlayback()
                return playbackSuccess
            }
            
            return false
        case .failure(let failure):
            print(failure)
            return false
        }
    }
    
    private func tapPlay() async {
        let removeSuccess = await cleanAnimations()
        
        if removeSuccess {
            let invokeSuccess = await invokePlayback()            
        }
    }
    
    private func determineFocused(newValue: Bool) async {
        if newValue && appMode == .animate {
            await initializeAndActionablesAdd()
        } else {
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
                            selectedActionabeIDTracker: selectedActionabeIDTracker,
                            webView: webView
                        )
                        .onChange(of: selectedActionabeIDTracker.selectedActionableIds) { _, newValue in
                            print(newValue)
                        }
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
                .onChange(of: isFocused) { _, newValue in
                    Task {
                        await determineFocused(newValue: newValue)
                    }
                }
            } trailing: {
                ScrollView {
                    VStack {
                        VStack(alignment: .leading) {
                            Picker(selection: $appMode) {
                                Text("Animate")
                                    .tag(AppMode.animate)
                                Text("Design")
                                    .tag(AppMode.design)
                            } label: {
                                EmptyView()
                            }
                            .pickerStyle(.segmented)
                            .padding(.vertical)
                            
                            HStack() {
                                FocusIndicator(isOn: $isFocused)
                                    .disabled(appMode != .animate)
                                Spacer(minLength: .zero)
                                Button {
                                    Task {
                                        await tapPlay()
                                    }
                                } label: {
                                    Image(systemName: "play")
                                }
                            }

                            AnimationsAvailableColumn(
                                animations: animations.map(\.id),
                                selected: $selectedAnimation,
                                actionableIds: $selectedActionabeIDTracker.wrappedValue.selectedActionableIds,
                                disabled: false) { animationId, actionableIds in
                                    editorModel.animations[animationId] = actionableIds
                                    print(editorModel.animations)
                                }
                                .padding(.vertical)
                        }
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal)
                        .modifier(WithPanelBackground())
                        .frame(minHeight: 375)
                        .cornerRadius(bottomLeft: cornerRadius)
                        
                        Spacer(minLength: spacing)
                        
                        VStack {
                            AnimationsAttachedList(animations: editorModel.animations[selectedAnimation] ?? Set())
                                .padding(.vertical)
                        }
                        .padding(.horizontal)
                        .modifier(WithPanelBackground())
                        .frame(minHeight: 300)
                        .frame(maxHeight: .infinity)
                        .cornerRadius(topLeft: cornerRadius)
                    }
                    .frame(maxWidth: propertiesViewWidth, maxHeight: .infinity)
                }
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
