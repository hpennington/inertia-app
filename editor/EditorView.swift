//
//  EditorView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI
import WebKit
import Inertia
import Virtualization

import Foundation
import Network

@Observable
class WebSocketServer {
    let listener: NWListener
    var clients: [UUID: NWConnection] = [:]
    var tree: Tree?
    var actionableIds: Set<String> = Set()
    
    let clientId = UUID()
    
    init(port: UInt16) throws {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        
        // Configure WebSocket options
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true  // Automatically respond to ping messages
        parameters.defaultProtocolStack.applicationProtocols.append(wsOptions)

        listener = try NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!)
        
        listener.newConnectionHandler = { [weak self] newConnection in
            self?.handleNewConnection(newConnection)
        }
    }

    func start() {
        print("WebSocket server starting on port \(listener.port!.rawValue)")
        listener.start(queue: .main)
    }

    private func handleNewConnection(_ connection: NWConnection) {
        clients[clientId] = connection

        connection.start(queue: .main)
        print("Accepted new client: \(clientId)")

        receiveMessage(on: connection, clientId: clientId)
    }

    private func receiveMessage(on connection: NWConnection, clientId: UUID) {
        connection.receiveMessage { [weak self] (data, context, isComplete, error) in
            if let error = error {
                print("Error receiving message: \(error)")
                self?.clients.removeValue(forKey: clientId)
                return
            }

            if let data = data, !data.isEmpty {
                guard let msg = try? JSONDecoder().decode(WebSocketSharedManager.MessageItem.self, from: data) else {
                    print("Failed to Decode Message")
                    return
                }
                print("Received message from client \(clientId): \(msg)")
//                self?.sendMessage(data, to: connection)
                
                self?.tree = msg.tree
                self?.actionableIds = msg.actionableIds
                
            }

            // Continue listening for more messages
            self?.receiveMessage(on: connection, clientId: clientId)
        }
    }
    
    func sendSelectedIds(_ ids: Set<String>) {
        guard let connection = clients[clientId] else {
            print("No connection")
            return
        }
        
        let messageItem = WebSocketSharedManager.MessageItem2(selectedIds: ids)
        let data = try! JSONEncoder().encode(messageItem)
        sendMessage(data, to: connection)
    }

    private func sendMessage(_ messageData: Data, to connection: NWConnection) {
//        let messageData = message.data(using: .utf8) ?? Data()
        let context = NWConnection.ContentContext(identifier: "WebSocketMessage", metadata: [NWProtocolWebSocket.Metadata(opcode: .binary)])
        
        connection.send(content: messageData, contentContext: context, isComplete: true, completion: .contentProcessed { error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                print("Sent message to client: \(messageData)")
            }
        })
    }
}

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
    var containers: [ActionableContainerAssociater] = []
    var animations: [ActionableAnimationAssociater] = []
}

struct ActionableAnimationAssociater: Hashable {
    let actionableIds: Set<String>
    let containerId: String
    let animationId: String
}

struct ActionableContainerAssociater: Hashable {
    let actionableIds: Set<String>
    let containerId: String
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
        url: Binding<String>,
        framework: SetupFlowFramework,
        animations: [VibeSchema],
        webView: WKWebView,
        contentController: WKUserContentController,
        configuration: WKWebViewConfiguration,
        delegate: AppDelegate
    ) {
        self._url = url
        self.framework = framework
        self.animations = animations
        self.webView = webView
        self.contentController = contentController
        self.configuration = configuration
        self.delegate = delegate
    }
    
    @State private var appMode: AppMode = .animate
    @State private var editorModel = EditorModel()
    @State private var isFocused = false
    @State private var frameSize: CGSize? = nil
    @State private var selectedActionabeIDTracker = SelectedActionableIDTracker()
    @State private var selectedAnimation: String = ""
    @State private var attachActionTitle: String = "Attach Container"
    @State private var downloadingMacOS: Bool = true
    @State private var restoreImageDownloadProgress: Double = .zero
    @State private var installationProgress: Double = .zero
    @State private var virtualMachine: VZVirtualMachine? = nil
    @State private var installerFatory: MacOSVMInstalledFactory? = nil
    
    @State private var server = try! WebSocketServer(port: 8060)
    
    let paths = VirtualMachinePaths()
    @Binding var url: String
    let framework: SetupFlowFramework
    let animations: [VibeSchema]
    let webView: WKWebView
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
            print(args.count)
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
    
    struct AnimationContainer: Codable, Hashable {
        let actionableId: String
        let containerId: String
    }
    
    struct Animation: Codable, Hashable {
        let actionableId: String
        let containerId: String
        let containerActionableId: String
        let animationId: String
    }
    
    struct VibeSchemaWrapper: Codable {
        let schema: VibeSchema
        let actionableId: String
        let container: EditorView.AnimationContainer
        let animationId: String
    }
    
    private func runInvokePlayback() async -> Bool {
        let relavantAnimations = Set(editorModel.animations.compactMap({element in
            let containerId = element.containerId
            let actionableIds = element.actionableIds
            
            if let container = editorModel.containers.first(where: { container in
                container.containerId == containerId
            }) {
                return actionableIds.map {
                    Animation(actionableId: $0, containerId: container.containerId, containerActionableId: container.actionableIds.first ?? "body-vibe-id", animationId: element.animationId)
                }
                .flatMap({$0})
            } else {
                return actionableIds.map {
                    Animation(actionableId: $0, containerId: containerId, containerActionableId: "body-vibe-id", animationId: element.animationId)
                }
                .flatMap({$0})
            }
            
        })
        .flatMap({$0}))
        
        let animationArgs = relavantAnimations.compactMap { (element: EditorView.Animation) -> String? in
            guard let schema = self.animations.first(where: {element.containerId == $0.id}) else {
                return nil
            }
            
            guard let container = self.animations.first(where: {$0.id == schema.id}) else {
                return nil
            }
            
            let updateSchema = VibeSchemaWrapper(schema: schema, actionableId: element.actionableId, container: AnimationContainer(actionableId: element.containerActionableId, containerId: container.id), animationId: element.animationId)
            
            guard let data = try? JSONEncoder().encode(updateSchema) else {
                return nil
            }
            
            return String(data: data, encoding: .utf8)
        }
        
        let result = await executeVibeWebFunction(function: "invokePlayback", args: animationArgs)
        
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
    
    var animationsAvailableContents: [String: [String]] {
        var map: [String: [String]] = [:]
        for animation in animations {
            map[animation.id] = animation.objects.map {
                $0.id
            }.sorted()
        }
        
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
    @State private var isVmLoaded = false
    @State private var installerFactory: MacOSVMInstalledFactory? = nil
    
    func convertTreeToTreeItem(tree: Tree) -> TreeItem? {
        guard let rootNode = tree.rootNode else { return nil }
        return convertNodeToTreeItem(node: rootNode)
    }

    private func convertNodeToTreeItem(node: Node) -> TreeItem {
        let children = node.children?.map { convertNodeToTreeItem(node: $0) } ?? []
        return TreeItem(
            id: node.id,
            displayName: node.id, // Use `id` directly as `displayName`
            children: children.isEmpty ? nil : children
        )
    }
    
    @ViewBuilder
    var treeView: some View {
        if let tree = server.tree {
            if let rootItem = convertTreeToTreeItem(tree: tree) {
                TreeView(id: rootItem.id, displayName: rootItem.displayName, rootItem: rootItem, isSelected: $server.actionableIds)
                    .padding(.vertical, 42)
                    .padding(.horizontal, 24)
                    .onChange(of: server.actionableIds) { _, newValue in
                        server.sendSelectedIds(newValue)
                    }
            } else {
                EmptyView()
            }
            
        } else {
            EmptyView()
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
                        VStack {
                            AddressBar(path: url) { newURL in
                                self.url = newURL
                            }
                            .frame(maxWidth: frameSize?.width)
                            
                            if let url = URL(string: url) {
                                WebRenderView(
                                    url: url,
                                    contentController: contentController,
                                    selectedActionabeIDTracker: selectedActionabeIDTracker,
                                    webView: webView
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(16 / 10, contentMode: .fit)
                                
                                
                                .cornerRadius(renderViewportCornerRadius)
//                                .frame(maxWidth: (frameSize?.height ?? viewportMinimumSize.height) * (16 / 9))
//                                .frame(maxHeight: (frameSize?.width ?? viewportMinimumSize.width) / (16 / 9))
                                .padding(6 / 2)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(colorScheme == .light ? ColorPalette.gray5 : ColorPalette.gray2, lineWidth: 6)
                                }
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear
                                            .onAppear {
                                                frameSize = maxCGSize(lhs: proxy.size, rhs: viewportMinimumSize)
                                            }
                                            .onChange(of: proxy.size) { oldValue, newValue in
                                                frameSize = maxCGSize(lhs: newValue, rhs: viewportMinimumSize)
                                            }
                                    }
                                )
                                .onChange(of: selectedActionabeIDTracker.selectedActionableIds) { _, newValue in
                                    print(newValue)
                                }
                            } else {
                                Color.black
                            }
                            
                            Spacer()
                        }
                        .background(appColors.backgroundPrimary)
                    case .swiftUI:
                        VStack {
                            if isVmLoaded {
                                if let virtualMachine {
                                    GeometryReader { proxy in
                                        MacRenderView(virtualMachine: virtualMachine, size: viewportMinimumSize)
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
                                        .task {
                                            server.start()

                                            // Keep the server running
//                                            RunLoop.main.run()
                                        }
                                }
                            } else {
                                ProgressView()
                                    .onAppear {
                                        let paths = VirtualMachinePaths()
                                        let downloader = MacOSVMDownloader(paths: paths) { value in
        //                                    progress = value
                                        }
                                        
                                        self.installerFactory = MacOSVMInstalledFactory(downloader: downloader, paths: paths) { progress in
        //                                    self.progress = progress
                                        }
                                        self.installerFactory?.createInitialzedVM(size: viewportMinimumSize, paths: paths, initCompletion: { vm in
                                            self.virtualMachine = vm
                                            self.delegate.paths = paths
                                            self.delegate.virtualMachine = vm
                                            self.isVmLoaded = true
                                        })
                                    }
                            }
                            
                            Spacer(minLength: .zero)
                        }
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
                                animations: animationsAvailableContents,
                                selected: $selectedAnimation,
                                actionableIds: $selectedActionabeIDTracker.wrappedValue.selectedActionableIds,
                                disabled: false,
                                actionTitle: attachActionTitle) { id, actionableIds in
                                    let containers = self.animations
                                    let animations = self.animations.flatMap({$0.objects})
                                    
                                    if let container = containers.first(where: { container in container.id == id }) {
                                        
                                        editorModel.containers.append(ActionableContainerAssociater(actionableIds: actionableIds, containerId: container.id))
                                    } else if let animation = animations.first(where: { animation in animation.id == id }) {
                                        editorModel.containers.append(ActionableContainerAssociater(actionableIds: Set(["body-vibe-id"]), containerId: animation.containerId))
                                        editorModel.animations.append(ActionableAnimationAssociater(actionableIds: actionableIds, containerId: animation.containerId, animationId: animation.id))
                                    }
                                }
                                .padding(.vertical)
                        }
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal)
                        .modifier(WithPanelBackground())
                        .frame(minHeight: 500)
                        .cornerRadius(bottomLeft: cornerRadius)
                        .onChange(of: selectedAnimation) { _, newValue in
                            let containers = self.animations
                            let animations = self.animations.flatMap({$0.objects})
                            if let container = containers.first(where: { container in container.id == newValue }) {
                                attachActionTitle = "Attach Container"
                            } else if let animation = animations.first(where: { animation in animation.id == newValue }) {
                                attachActionTitle = "Attach Animation"
                            }
                        }
                        
                        Spacer(minLength: spacing)
                        
                        VStack {
//                            AnimationsAttachedList(animations: editorModel.animations)
//                                .padding(.vertical)
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
                PanelView(color: colorScheme == .light ? ColorPalette.gray6 : ColorPalette.gray0_5)
                    .frame(height: timelineViewHeight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appColors.backgroundSecondary)
        .environment(\.appColors, appColors)
    }
}
