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

@Observable
public final class EditorModel {
    public var animations: [InertiaID: InertiaAnimationSchema] = [:]
}

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
        delegate: AppDelegate
    ) {
        self._url = url
        self._framework = framework
        self._animations = animations
        self.webView = webView
        self.coordinator = coordinator
        self.contentController = contentController
        self.configuration = configuration
        self.delegate = delegate
    }
    
//    @State private var appMode: AppMode = .react
    @State private var editorModel = EditorModel()
    @State private var isFocused = false
    @State private var frameSize: CGSize? = nil
    @State private var selectedAnimation: String = ""
    @State private var attachActionTitle: String = "Attach Container"
    @State private var virtualMachineMacOS: VZVirtualMachine? = nil
    @State private var virtualMachineLinux: VZVirtualMachine? = nil
    
    @State private var serverManager = WebSocketServerManager()
    @State private var playbackManager: PlaybackManager? = nil
    @State private var keyframeHandler: KeyframeHandler? = nil


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
        guard let playbackManager = playbackManager else { return }
        await playbackManager.play()
    }
    
    private func determineFocused(newValue: Bool) async {
        // TODO: Does this eneed sometings?
    }
    
    var animationsAvailableContents: [String: [String]] {
        var map: [String: [String]] = [:]
//        for animation in animations {
//            map[animation.id] = animation.objects.map {
//                $0.id
//            }.sorted()
//        }
        
        return map
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
    
    @State private var isMacOSVMLoaded = false
    @State private var isLinuxVMLoaded = false
    
    @ViewBuilder
    var treeView: some View {
        if let server = serverManager.servers[framework] {
            TreeViewContainer(appMode: framework, isFocused: $isFocused, server: server) { ids in

//                var localRowData: [String: [Int]] = rowData
//                for id in ids {
//                    if !localRowData.contains(where: { pair in
//                        pair.key == id
//                    }) {
//                        localRowData[id] = [Int]()
//                    }
//                }
//
//                self.rowData = localRowData
            }
            .id(server.clients.keys.description)
        }

    }
    
    func attachAnimation(id: String, actionableIds: Set<String>) {
//        let containers = self.animations
//        let animations = self.animations.flatMap({$0.objects})
//        
//        if let container = containers.first(where: { container in container.id == id }) {
//            
//            editorModel.containers.append(ActionableContainerAssociater(actionableIds: actionableIds, containerId: container.id))
//        } else if let animation = animations.first(where: { animation in animation.id == id }) {
//            editorModel.containers.append(ActionableContainerAssociater(actionableIds: Set(["animation1"]), containerId: animation.containerId))
//            
//            if let server = servers[framework] {
//                for treePacket in server.treePackets {
//                    for id in treePacket.actionableIds {
//                        selectedActionableIDTracker?.selectedActionableIds.insert(id)
//                    }
//                }
//                
//                if let selectedActionableIds = selectedActionableIDTracker?.selectedActionableIds {
//                    editorModel.animations.append(
//                        ActionableAnimationAssociater(
//                            actionableIds: selectedActionableIds,
//                            containerId: animation.containerId,
//                            animationId: animation.id
//                        )
//                    )
//                }
//                   
//            }
//        }
    }
    
    var timelineView: some View {
        PanelView(color: colorScheme == .light ? ColorPalette.gray6 : ColorPalette.gray0_5)
            .frame(height: timelineViewHeight)
            .overlay {
                if let playbackManager = playbackManager {
                    TimelineContainer(
                        playheadTime: Binding(
                            get: { playbackManager.playheadTime },
                            set: { playbackManager.playheadTime = $0 }
                        ),
                        actionableIds: Set(editorModel.animations.keys),
                        keyframes: playbackManager.keyframes,
                        isPlaying: Binding(
                            get: { playbackManager.isPlaying },
                            set: { playbackManager.isPlaying = $0 }
                        )
                    )
                    .onChange(of: playbackManager.isPlaying) { oldValue, newValue in
                        Task {
                            await tapPlay()
                        }
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
        keyframeHandler?.createKeyframe(message: message, initialValues: initialValues)
    }
    
    @ViewBuilder
    var composeView: some View {
        LinuxVMView(
            isLoaded: $isLinuxVMLoaded,
            virtualMachine: $virtualMachineLinux,
            frameSize: $frameSize,
            servers: $serverManager.servers,
            viewportMinimumSize: viewportMinimumSize,
            renderViewportCornerRadius: renderViewportCornerRadius,
            delegate: delegate,
            onKeyframeMessage: createKeyframe
        )
    }
    
    var macOSView: some View {
        MacOSVMView(
            isLoaded: $isMacOSVMLoaded,
            virtualMachine: $virtualMachineMacOS,
            frameSize: $frameSize,
            servers: $serverManager.servers,
            viewportMinimumSize: viewportMinimumSize,
            renderViewportCornerRadius: renderViewportCornerRadius,
            delegate: delegate,
            onKeyframeMessage: createKeyframe,
            playheadTime: playbackManager?.playheadTime ?? .zero
        )
    }
    
    var reactView: some View {
        ReactRenderView(
            frameSize: $frameSize,
            servers: $serverManager.servers,
            url: url,
            viewportMinimumSize: viewportMinimumSize,
            renderViewportCornerRadius: renderViewportCornerRadius,
            contentController: contentController,
            coordinator: coordinator,
            webView: webView,
            onKeyframeMessage: createKeyframe,
            playheadTime: playbackManager?.playheadTime ?? .zero
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
                        animations: animationsAvailableContents,
                        selected: $selectedAnimation,
                        actionableIds: Set(),
                        disabled: false,
                        actionTitle: attachActionTitle, attachAnimation: self.attachAnimation)
                        .padding(.vertical)
                    
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
                .modifier(WithPanelBackground())
                .frame(minHeight: 600)
                .cornerRadius(bottomLeft: cornerRadius)
                .onChange(of: selectedAnimation) { _, newValue in
//                    let containers = self.animations
//                    let animations = self.animations.flatMap({$0.objects})
//                    if let container = containers.first(where: { container in container.id == newValue }) {
//                        attachActionTitle = "Attach Container"
//                    } else if let animation = animations.first(where: { animation in animation.id == newValue }) {
//                        attachActionTitle = "Attach Animation"
//                    }
                }
                
                Spacer(minLength: spacing)
                
                VStack {
//                            AnimationsAttachedList(animations: editorModel.animations)
//                                .padding(.vertical)
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
                animationPropertyView
            } bottom: {
                timelineView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appColors.backgroundSecondary)
        .environment(\.appColors, appColors)
        .onAppear {
            // Initialize managers
            playbackManager = PlaybackManager(
                editorModel: editorModel,
                serverManager: serverManager,
                framework: framework
            )
            keyframeHandler = KeyframeHandler(
                editorModel: editorModel,
                playbackManager: playbackManager!,
                animations: $animations
            )
        }
        .onChange(of: framework) { _, newValue in
            playbackManager?.updateFramework(newValue)
        }
    }
}
