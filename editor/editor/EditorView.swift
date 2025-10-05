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

//@Observable
//final class SelectedActionableIDTracker {
//    var selectedActionableIds: Set<String> = []
//}

@Observable
public final class EditorModel {
    public var animations: [InertiaID: InertiaAnimationSchema] = [:]
//    public var containers: [ActionableContainerAssociater] = []
//    public var animations: [ActionableAnimationAssociater] = []
}

//public struct ActionableAnimationAssociater: Hashable {
//    public let actionableIds: Set<String>
//    public let containerId: String
//    public let animationId: String
//}
//
//public struct ActionableContainerAssociater: Hashable {
//    public let actionableIds: Set<String>
//    public let containerId: String
//}

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
    @State private var downloadingMacOS: Bool = true
    @State private var restoreImageDownloadProgress: Double = .zero
    @State private var installationProgress: Double = .zero
    @State private var virtualMachineMacOS: VZVirtualMachine? = nil
    @State private var virtualMachineLinux: VZVirtualMachine? = nil
//    @State private var installerFatory: MacOSVMInstalledFactory? = nil
    @State private var installerFactoryLinux: LinuxVMFactory? = nil
    @State private var playheadTime: CGFloat = .zero
    
//    @State private var server: WebSocketServer? = nil
    @State private var servers: [SetupFlowFramework: WebSocketServer] = [:]

    
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
    
    func executeInertiaSwiftWebsocketFunction(schemaWrappers: [InertiaSchemaWrapper]) async -> Result<Int, InertiaSwiftWebsocketError> {
        guard let server = servers[framework] else {
            return .failure(.serverNil)
        }
        
        for client in server.clients {
            if client.value.state == .ready {
                server.sendSchema(schemaWrappers, to: client.key)
            } else {
                return .failure(.serverNil)
            }
        }
        
        return .success(1)
    }
    
    private func runInvokePlayback() async -> Bool {
        
        
//        let relavantAnimations = Set(editorModel.animations.compactMap({element in
//            let key = element.key
//            let v = element.value.id
//            
//        })
//        .flatMap({$0}))
//        
//        let animationArgs = relavantAnimations.compactMap { (element: InertiaAnimation) -> InertiaSchemaWrapper? in
//            guard let schema = self.animations.first(where: {element.containerId == $0.id}) else {
//                return nil
//            }
//            
//            guard let container = self.animations.first(where: {$0.id == schema.id}) else {
//                return nil
//            }
//            
//            let updateSchema = InertiaSchemaWrapper(schema: schema, actionableId: element.actionableId, container: AnimationContainer(actionableId: element.containerActionableId, containerId: container.id), animationId: element.animationId)
//            
//            return updateSchema
//        }
//        
//        let result = await executeInertiaSwiftWebsocketFunction(schemaWrappers: animationArgs)
//        
//        switch result {
//        case .success(let success):
//            return success == 1
//        case .failure(let failure):
//            print(failure)
//            return false
//        }
        return true
    }
    
    private func tapPlay() async {
        print(await runInvokePlayback())
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
    
    @State private var installOpacity = CGFloat.zero
    @State private var isMacOSVMLoaded = false
    @State private var isLinuxVMLoaded = false
    @State private var installerFactory: MacOSVMInstalledFactory? = nil
    @State private var isPlaying: Bool = false
    @State private var keyframes: [InertiaAnimationKeyframe] = []
    
    @ViewBuilder
    var treeView: some View {
        if let server = servers[framework] {
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
                TimelineContainer(playheadTime: $playheadTime, isPlaying: $isPlaying)
            }
            .onChange(of: isPlaying) { oldValue, newValue in
                Task {
                    await tapPlay()
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
//        print(message)
//        print(animations)
//        
//        
//        
//        let values = InertiaAnimationValues(
//            scale: 1.0,
//            translate: .init(width: message.translationX, height: message.translationY),
//            rotate: .zero,
//            rotateCenter: .zero,
//            opacity: 1.0
//        )
//
//        let newKeyframe = InertiaAnimationKeyframe(id: UUID().uuidString, values: values, duration: 1.0)
//        keyframes.append(newKeyframe)
//        
//        
//        let initialValues = initialValues ?? InertiaAnimationValues(
//            scale: 1.0,
//            translate: .zero,
//            rotate: .zero,
//            rotateCenter: .zero,
//            opacity: 1.0
//        )
//        
//        
//        for id in message.actionableIds {
//            let rectangle = InertiaShape(
//                id: "bird2",
//                containerId: "animation", // or "animation123schema" if you want a new container
//                width: 200,
//                height: 100,
//                position: .zero,
//                color: [127, 244, 122],
//                shape: "rectangle",
//                objectType: .animation, // ✅ was .animation
//                zIndex: 0,
//                animation: .init(
//                    id: "card0",
//                    actionableid: id,
//                    initialValues: initialValues,
//                    invokeType: .auto,
//                    keyframes: keyframes
//                )
//            )
//            
//            if let animationIndex = animations.firstIndex(where: { schema in
//                schema.id == "animation"
//            }) {
//                animations[animationIndex] = InertiaSchema(id: "animation", objects: [rectangle])
//            } else {
//                animations.append(InertiaSchema(id: "animation", objects: [rectangle]))
//                editorModel.animations.append(ActionableAnimationAssociater(actionableIds: message.actionableIds, containerId: "animation", animationId: id))
//            }
//        }
//        
        
    }
    
    @ViewBuilder
    var composeView: some View {
        VStack {
            if self.isLinuxVMLoaded {
                if let virtualMachineLinux {
                    GeometryReader { proxy in
                        MacRenderView(virtualMachine: virtualMachineLinux, paths: VirtualMachinePaths(system: .linux), size: viewportMinimumSize)
                            .onAppear {
                                frameSize = maxCGSize(lhs: proxy.size, rhs: viewportMinimumSize)
                            }
                            .onChange(of: proxy.size) { oldValue, newValue in
                                frameSize = maxCGSize(lhs: newValue, rhs: viewportMinimumSize)
                            }
                    }
                    .aspectRatio(16 / 10, contentMode: .fit)
                    .cornerRadius(renderViewportCornerRadius)
                    .padding(6 / 2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(colorScheme == .light ? ColorPalette.gray5 : ColorPalette.gray2, lineWidth: 6)
                    }
                    .onAppear {
                        if servers[.compose] == nil {
                            if let server = try? WebSocketServer(port: 8070) { message in
                                createKeyframe(message: message)
                            } {
                                server.start()
                                servers[.compose] = server
                            }
                        }
                    }
                }
            } else {
                ProgressView()
                    .onAppear {
                        let paths = VirtualMachinePaths(system: .linux)
                        self.installerFactoryLinux = LinuxVMFactory(size: viewportMinimumSize, paths: paths)
                        
                        if FileManager.default.fileExists(atPath: paths.diskImageURL.path) {
                            // Linux is already installed, boot normally
                            self.virtualMachineLinux = self.installerFactoryLinux?.createVMForBoot()
                        } else {
                            // Linux not installed, boot from ISO for installation
                            self.virtualMachineLinux = self.installerFactoryLinux?.createVMForInstallation(isoURL: URL("/Users/haydenpennington/Downloads/ubuntu-25.04-desktop-arm64.iso")!)
                        }
                        self.delegate.vmShutdownManagers.append(VirtualMachineShutdownManager(virtualMachine: self.virtualMachineLinux, paths: paths))
                        
                        self.virtualMachineLinux?.start { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success:
                                    self.isLinuxVMLoaded = true
                                case .failure(let error):
                                    print("Failed to start VM: \(error)")
                                }
                            }
                        }
                    }
            }
            
            Spacer(minLength: .zero)
        }   
    }
    
    var macOSView: some View {
        VStack {
            if isMacOSVMLoaded {
                if let virtualMachineMacOS {
                    GeometryReader { proxy in
                        MacRenderView(virtualMachine: virtualMachineMacOS, paths: VirtualMachinePaths(system: .macos), size: viewportMinimumSize)
                            .onAppear {
                                frameSize = maxCGSize(lhs: proxy.size, rhs: viewportMinimumSize)
                            }
                            .onChange(of: proxy.size) { oldValue, newValue in
                                frameSize = maxCGSize(lhs: newValue, rhs: viewportMinimumSize)
                            }
                        }
                        .aspectRatio(16 / 10, contentMode: .fit)
                        .cornerRadius(renderViewportCornerRadius)
                        .padding(6 / 2)
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(colorScheme == .light ? ColorPalette.gray5 : ColorPalette.gray2, lineWidth: 6)
                        }
                        .onAppear {
                            if servers[.swiftUI] == nil {
                                if let server = try? WebSocketServer(port: 8060) { message in
                                    if playheadTime == .zero {
                                        let initialValues = InertiaAnimationValues(
                                            scale: 1.0,
                                            translate: .zero,
                                            rotate: .zero,
                                            rotateCenter: .zero,
                                            opacity: 1.0
                                        )
                                        createKeyframe(message: message, initialValues: initialValues)
                                    } else {
                                        createKeyframe(message: message)
                                    }
                                } {
                                    server.start()
                                    servers[.swiftUI] = server
                                }
                            }
                        }
                }
            } else {
                ProgressView()
                    .onAppear {
                        let paths = VirtualMachinePaths(system: .macos)
                        let downloader = MacOSVMDownloader(paths: paths) { value in
//                                    progress = value
                        }
                        
                        self.installerFactory = MacOSVMInstalledFactory(downloader: downloader, paths: paths) { progress in
//                                    self.progress = progress
                        }
                        self.installerFactory?.createInitialzedVM(size: viewportMinimumSize, paths: paths, initCompletion: { vm in
                            self.virtualMachineMacOS = vm
                            self.delegate.vmShutdownManagers.append(VirtualMachineShutdownManager(virtualMachine: vm, paths: paths))
                            self.isMacOSVMLoaded = true
                        })
                    }
            }
            
            Spacer(minLength: .zero)
        }
    }
    
    var reactView: some View {
        VStack {
            GeometryReader { proxy in
                if let url = URL(string: url) {
                    WebRenderView(
                        url: url,
                        contentController: contentController,
                        coordinator: coordinator,
                        webView: webView
                    )
                    .equatable()
                    .id(url)
                    .frame(width: 300)
                    
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(16 / 10, contentMode: .fit)
                    .background(Color.black)
                    .cornerRadius(renderViewportCornerRadius)
                    .padding(6 / 2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(colorScheme == .light ? ColorPalette.gray5 : ColorPalette.gray2, lineWidth: 6)
                    }
                    .onAppear {
                        frameSize = maxCGSize(lhs: proxy.size, rhs: viewportMinimumSize)
                    }
                    .onChange(of: proxy.size) { oldValue, newValue in
                        frameSize = maxCGSize(lhs: newValue, rhs: viewportMinimumSize)
                    }
                    .onAppear {
                        if servers[.react] == nil {
                            if let server = try? WebSocketServer(port: 8080) { message in
                                if playheadTime == .zero {
                                    let initialValues = InertiaAnimationValues(
                                        scale: 1.0,
                                        translate: .init(width: message.translationX, height: message.translationY),
                                        rotate: .zero,
                                        rotateCenter: .zero,
                                        opacity: 1.0
                                    )
                                    createKeyframe(message: message, initialValues: initialValues)
                                } else {
                                    createKeyframe(message: message)
                                }
                            } {
                                server.start()
                                servers[.react] = server
                            }
                        }
                    }
                } else {
                    Color.black
                }
                Spacer()
            }
        }
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
    }
}
