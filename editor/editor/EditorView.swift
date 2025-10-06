//
//  EditorView.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI
import WebKit
import Inertia
import Virtualization
import Foundation
import Observation

@MainActor
struct EditorView: View {
    @Environment(\.colorScheme) var colorScheme
    @FocusState var focusState: FocusableElement?

    enum FocusableElement: Hashable {
        case viewport
    }

    private let hierarchyViewWidth: CGFloat = 300
    private let viewportMinimumSize = CGSize(width: 320, height: 180)
    private let propertiesViewWidth: CGFloat = 300
    private let timelineViewHeight: CGFloat = 300
    private let renderViewportCornerRadius: CGFloat = 4
    private let segmentedPickerWidth: CGFloat = 250
    private let spacing: CGFloat = 3
    private let cornerRadius: CGFloat = 4

    init(
        url: Binding<String>,
        framework: Binding<SetupFlowFramework>,
        animations: Binding<[InertiaAnimationSchema]>,
        webView: WKWebView,
        coordinator: WKWebViewWrapper.Coordinator,
        contentController: WKUserContentController,
        configuration: WKWebViewConfiguration,
        delegate: AppDelegate,
        viewModel: EditorViewModel
    ) {
        self._url = url
        self._framework = framework
        self._animations = animations
        self.webView = webView
        self.coordinator = coordinator
        self.contentController = contentController
        self.configuration = configuration
        self.delegate = delegate
        self._viewModel = State(wrappedValue: viewModel)
    }

    @State var viewModel: EditorViewModel

    @Binding var url: String
    @Binding var framework: SetupFlowFramework
    @Binding var animations: [InertiaAnimationSchema]
    let webView: WKWebView
    let coordinator: WKWebViewWrapper.Coordinator
    let contentController: WKUserContentController
    let configuration: WKWebViewConfiguration
    let delegate: AppDelegate
    
    var appColors: Colors {
        colorScheme == .dark ? ColorsDark() : ColorsLight()
    }
    
    struct WithPanelBackground: ViewModifier {
        let color: Color?
        
        init(color: Color? = nil) {
            self.color = color
        }
        
        func body(content: Content) -> some View {
            ZStack {
                PanelView(color: color)
                content
            }
        }
    }
    
    func maxCGSize(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
    }
    
    private func tapPlay() async {
        await viewModel.play()
    }

    func transformTreeToTreeItems(node: Node) -> TreeItem {
        var childrenOut: [TreeItem]? = nil
        if let children = node.children {
            for child in children {
                childrenOut?.append(transformTreeToTreeItems(node: child))
            }
        }

        return TreeItem(id: node.id, displayName: node.id, children: childrenOut)
    }

    @ViewBuilder
    var treeView: some View {
        if let server = viewModel.serverManager.servers[framework] {
            TreeViewContainer(appMode: framework, isFocused: $viewModel.isFocused, server: server) { ids in
                // Handle tree selection updates
            }
            .id(server.clients.keys.description)
        }
    }
    
    var timelineView: some View {
        let _ = viewModel.keyframesVersion // Force dependency tracking

        return PanelView(color: colorScheme == .light ? ColorPalette.gray6 : ColorPalette.gray0_5)
            .frame(height: timelineViewHeight)
            .overlay {
                TimelineContainer(
                    playheadTime: Binding(
                        get: { viewModel.playbackManager.playheadTime },
                        set: { viewModel.playbackManager.playheadTime = $0 }
                    ),
                    actionableIds: Set(viewModel.animations.keys),
                    keyframes: viewModel.playbackManager.keyframes,
                    isPlaying: Binding(
                        get: { viewModel.playbackManager.isPlaying },
                        set: { viewModel.playbackManager.isPlaying = $0 }
                    )
                )
                .onChange(of: viewModel.keyframesVersion) { oldValue, newValue in
                    print("📊 Timeline notified of keyframes version change: \(oldValue) -> \(newValue)")
                }
                .onChange(of: viewModel.playbackManager.isPlaying) { oldValue, newValue in
                    Task {
                        await tapPlay()
                    }
                }
            }
    }
    
    func showExportPanel() {
        let panel = NSSavePanel()
        panel.title = "Export animation file"
        panel.nameFieldStringValue = "animation.json"
        panel.isExtensionHidden = false
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                exportAnimationFile(url: url)
            }
        }
    }
    
    func exportAnimationFile(url: URL) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys] // optional: makes JSON readable and keys ordered

        do {
            let jsonData = try encoder.encode(animations.first)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                _exportAnimationFile(text: jsonString, url: url)
            }
        } catch {
            print("Error encoding JSON: \(error)")
        }
    }
        
    func _exportAnimationFile(text: String, url: URL) {
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    func createKeyframe(message: WebSocketClient.MessageTranslation, initialValues: InertiaAnimationValues? = nil) {
        viewModel.createKeyframe(message: message, initialValues: initialValues)
    }
    
    @ViewBuilder
    var composeView: some View {
        LinuxVMView(
            isLoaded: $viewModel.isLinuxVMLoaded,
            virtualMachine: $viewModel.virtualMachineLinux,
            frameSize: $viewModel.frameSize,
            servers: $viewModel.serverManager.servers,
            viewportMinimumSize: viewportMinimumSize,
            renderViewportCornerRadius: renderViewportCornerRadius,
            delegate: delegate,
            onKeyframeMessage: createKeyframe
        )
    }

    var macOSView: some View {
        MacOSVMView(
            isLoaded: $viewModel.isMacOSVMLoaded,
            virtualMachine: $viewModel.virtualMachineMacOS,
            frameSize: $viewModel.frameSize,
            servers: $viewModel.serverManager.servers,
            viewportMinimumSize: viewportMinimumSize,
            renderViewportCornerRadius: renderViewportCornerRadius,
            delegate: delegate,
            onKeyframeMessage: createKeyframe,
            playheadTime: viewModel.playheadTime
        )
    }

    var reactView: some View {
        ReactRenderView(
            frameSize: $viewModel.frameSize,
            servers: $viewModel.serverManager.servers,
            url: url,
            viewportMinimumSize: viewportMinimumSize,
            renderViewportCornerRadius: renderViewportCornerRadius,
            contentController: contentController,
            coordinator: coordinator,
            webView: webView,
            onKeyframeMessage: createKeyframe,
            playheadTime: viewModel.playheadTime
        )
        .background(appColors.backgroundPrimary)
    }
    
    @ViewBuilder
    var animationPropertyView: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    Picker(selection: $framework) {
                        Text("React")
                            .tag(SetupFlowFramework.react)
                        Text("SwiftUI")
                            .tag(SetupFlowFramework.swiftUI)
                        Text("Compose")
                            .tag(SetupFlowFramework.compose)
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical)
                    
                    HStack() {
                        if framework == .react {
                            AddressBar(path: url) { newURL in
                                self.url = newURL
                            }
                            .frame(maxWidth: .infinity)
                        }
                        Spacer()
                        SettingsIconButton {
                            showExportPanel()
                        }
                    }

                    AnimationsAvailableColumn(
                        animations: viewModel.animationsAvailableContents,
                        selected: $viewModel.selectedAnimation,
                        actionableIds: Set(),
                        disabled: false,
                        actionTitle: viewModel.attachActionTitle, attachAnimation: viewModel.attachAnimation)
                        .padding(.vertical)
                    
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
                .modifier(WithPanelBackground())
                .frame(minHeight: 600)
                .cornerRadius(bottomLeft: cornerRadius)

                Spacer(minLength: spacing)

                VStack {
                    // Animation attachments list
                }
                .padding(.horizontal)
                .modifier(WithPanelBackground())
                .frame(minHeight: 600)
                .frame(maxHeight: .infinity)
                .cornerRadius(topLeft: cornerRadius)
            }
            .frame(maxWidth: propertiesViewWidth, maxHeight: .infinity)
        }
    }
    
    var body: some View {
        VStack {
            MainLayout {
                PanelView()
                    .frame(width: hierarchyViewWidth)
                    .frame(maxHeight: .infinity)
                    .overlay(alignment: .topLeading) {
                        treeView
                    }
            } content: {
                Group {
                    switch framework {
                    case .react:
                        reactView
                    case .swiftUI:
                        macOSView
                    case .compose:
                        composeView
                    }
                }
                .padding()
                .modifier(WithPanelBackground())
                .frame(minWidth: viewModel.frameSize?.width ?? viewportMinimumSize.width, minHeight: viewModel.frameSize?.height ?? viewportMinimumSize.height)
                .focused($focusState, equals: .viewport)
                .onAppear {
                    focusState = .viewport
                }

            } trailing: {
                animationPropertyView
            } bottom: {
                timelineView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appColors.backgroundSecondary)
        .environment(\.appColors, appColors)
        .onChange(of: framework) { _, newValue in
            viewModel.updateFramework(newValue)
        }
        .onChange(of: viewModel.animations) { _, newValue in
            viewModel.playbackManager.updateAnimations(newValue)
            viewModel.keyframeHandler.updateAnimations(newValue)
        }
    }
}
