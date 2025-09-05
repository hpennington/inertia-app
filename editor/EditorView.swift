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

var fakeDB = """
{
    "id": "animation1",
    "objects": [
        {
            "id": "triangle0",
            "containerId": "animation1",
            "width": 400,
            "height": 400,
            "position": [-0.15, 0.1],
            "color": [0.3, 0.5, 1.0, 0.75],
            "shape": "triangle",
            "objectType": "shape",
            "zIndex": 0,
            "animation": {
                "id": "triangle0",
                "initialValues": {
                    "opacity": 1.0,
                    "rotate": 0.0,
                    "rotateCenter": 0.0,
                    "scale": 1.0,
                    "translate": [0.0, 0.0]
                },
                "invokeType": "auto",
                "keyframes": [
                    {
                        "id": "1",
                        "duration": 1,
                        "values": {
                            "scale": 0.25,
                            "translate": [0.0, 0.0],
                            "rotate": 0.0,
                            "rotateCenter": 45.0,
                            "opacity": 1.0
                        }
                    },
                    {
                        "id": "2",
                        "duration": 1,
                        "values": {
                            "scale": 0.5,
                            "translate": [0.0, 0.0],
                            "rotate": 0.0,
                            "rotateCenter": 90.0,
                            "opacity": 1.0
                        }
                    },
                    {
                        "id": "3",
                        "duration": 1,
                        "values": {
                            "scale": 0.75,
                            "translate": [0.0, 0.0],
                            "rotate": 90,
                            "rotateCenter": 180.0,
                            "opacity": 1.0
                        }
                    },
                    {
                        "id": "4",
                        "duration": 1,
                        "values": {
                            "scale": 1.0,
                            "translate": [0.0, 0.0],
                            "rotate": 180.0,
                            "rotateCenter": 360.0,
                            "opacity": 1.0
                        }
                    }
                ]
            }
        },
        {
            "id": "homeCard",
            "containerId": "animation1",
            "width": 100,
            "height": 100,
            "position": [0.1, 0.1],
            "color": [1.0, 0.5, 0.5, 0.75],
            "shape": "triangle",
            "objectType": "animation",
            "zIndex": 1,
            "animation": {
                "id": "homeCard",
                "initialValues": {
                    "opacity": 1.0,
                    "rotate": 0.0,
                    "rotateCenter": 0.0,
                    "scale": 1.0,
                    "translate": [0.0, 0.0]
                },
                "invokeType": "auto",
                "keyframes": [
                    {
                        "id": "1",
                        "duration": 1,
                        "values": {
                            "scale": 1.0,
                            "translate": [0.0, 0.0],
                            "rotate": 0.0,
                            "rotateCenter": -45.0,
                            "opacity": 1.0
                        }
                    },
                    {
                        "id": "2",
                        "duration": 1,
                        "values": {
                            "scale": 0.5,
                            "translate": [0.1, 0.01],
                            "rotate": 0.0,
                            "rotateCenter": -90.0,
                            "opacity": 1.0
                        }
                    },
                    {
                        "id": "3",
                        "duration": 1,
                        "values": {
                            "scale": 0.75,
                            "translate": [0.0, 0.0],
                            "rotate": -90,
                            "rotateCenter": -180.0,
                            "opacity": 1.0
                        }
                    },
                    {
                        "id": "4",
                        "duration": 1,
                        "values": {
                            "scale": 0.25,
                            "translate": [-1.0, 0.0],
                            "rotate": -180.0,
                            "rotateCenter": -360.0,
                            "opacity": 1.0
                        }
                    }
                ]
            }
        },
        {
            "id": "bird",
            "containerId": "animation1",
            "width": 150,
            "height": 150,
            "position": [0.7, -0.1],
            "color": [0.5, 0.5, 1.0, 0.8],
            "shape": "triangle",
            "objectType": "animation",
            "zIndex": 1,
            "animation": {
                "id": "bird",
                "initialValues": {
                    "opacity": 1.0,
                    "rotate": 0.0,
                    "rotateCenter": 0.0,
                    "scale": 1.0,
                    "translate": [0.0, 0.0]
                },
                "invokeType": "auto",
                "keyframes": [
                    {
                        "id": "1",
                        "duration": 0.5,
                        "values": {
                            "scale": 1.2,
                            "translate": [1.0, 1.0],
                            "rotate": 30.0,
                            "rotateCenter": 60.0,
                            "opacity": 0.9
                        }
                    },
                    {
                        "id": "2",
                        "duration": 0.5,
                        "values": {
                            "scale": 1.1,
                            "translate": [1.0, 1.0],
                            "rotate": 45.0,
                            "rotateCenter": 90.0,
                            "opacity": 0.8
                        }
                    }
                ]
            }
        },
        {
            "id": "car",
            "containerId": "animation1",
            "width": 250,
            "height": 250,
            "position": [0.1, 0.1],
            "color": [1.0, 0.3, 0.3, 0.6],
            "shape": "triangle",
            "objectType": "animation",
            "zIndex": 1,
            "animation": {
                "id": "car",
                "initialValues": {
                    "opacity": 1.0,
                    "rotate": 0.0,
                    "rotateCenter": 0.0,
                    "scale": 1.0,
                    "translate": [0.0, 0.0]
                },
                "invokeType": "trigger",
                "keyframes": [
                    {
                        "id": "1",
                        "duration": 3,
                        "values": {
                            "scale": 1.0,
                            "translate": [1.0, 0.5],
                            "rotate": 15.0,
                            "rotateCenter": 30.0,
                            "opacity": 0.95
                        }
                    },
                    {
                        "id": "2",
                        "duration": 3,
                        "values": {
                            "scale": 1.3,
                            "translate": [1.0, 1.0],
                            "rotate": 30.0,
                            "rotateCenter": 60.0,
                            "opacity": 0.85
                        }
                    }
                ]
            }
        }
    ]
}
"""

@Observable
final class TreePacket: Identifiable, Equatable, Hashable, CustomStringConvertible {
    public let id = UUID()
    static func == (lhs: TreePacket, rhs: TreePacket) -> Bool {
        lhs.id == rhs.id && lhs.tree == rhs.tree && lhs.actionableIds == rhs.actionableIds
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(tree)
        hasher.combine(actionableIds)
    }
    
    var description: String {
        "tree: \(tree), actionableIds: \(actionableIds)"
    }
    
    var tree: Tree
    var actionableIds: Set<String>
    
    init(tree: Tree, actionableIds: Set<String>) {
        self.tree = tree
        self.actionableIds = actionableIds
    }
}

import Network
import Observation

@Observable
final class WebSocketServer {
    let listener: NWListener
    var clients: [UUID: NWConnection] = [:]
    var treePackets: [TreePacket] = []
    var treePacketsLUT: [String: Int] = [:]

    init(port: UInt16) throws {
        // Configure WebSocket over TCP
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true
        parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)

        listener = try NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!)

        // Set handlers before starting
        listener.newConnectionHandler = { [weak self] connection in
            self?.handleNewConnection(connection)
        }

        listener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ Listener ready on port \(self.listener.port!.rawValue)")
            case .failed(let error):
                print("❌ Listener failed: \(error)")
            case .cancelled:
                print("⚠️ Listener cancelled")
            default:
                break
            }
        }
    }

    func start() {
        // Start listener last, after setting handlers
        listener.start(queue: .main)
    }


    private func handleNewConnection(_ connection: NWConnection) {
        let clientId = UUID()
        clients[clientId] = connection

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ Client connected: \(clientId)")
                self.receiveNextMessage(on: connection, clientId: clientId)
            case .failed(let error):
                print("❌ Connection failed: \(error)")
                self.clients.removeValue(forKey: clientId)
            case .cancelled:
                print("⚠️ Connection cancelled: \(clientId)")
                self.clients.removeValue(forKey: clientId)
            default:
                break
            }
        }

        connection.start(queue: .main)
    }

    private func receiveNextMessage(on connection: NWConnection, clientId: UUID) {
        connection.receiveMessage { [weak self] data, context, _, error in
            defer {
                if error == nil {
                    self?.receiveNextMessage(on: connection, clientId: clientId)
                }
            }

            if let error = error {
                print("❌ Receive error: \(error)")
                self?.clients.removeValue(forKey: clientId)
                return
            }

            guard let context = context else { return }
            if let wsMetadata = context.protocolMetadata(definition: NWProtocolWebSocket.definition) as? NWProtocolWebSocket.Metadata {
                switch wsMetadata.opcode {
                case .close:
                    print("🔌 Client closed connection: \(clientId)")
                    self?.clients.removeValue(forKey: clientId)
                    return
                case .ping, .pong:
                    return // Auto-replied
                default:
                    break
                }
            }

            guard let data = data else { return }

            if let wsMetadata = context.protocolMetadata(definition: NWProtocolWebSocket.definition) as? NWProtocolWebSocket.Metadata,
               wsMetadata.opcode == .text {
                if let text = String(data: data, encoding: .utf8) {
                    print("📥 Received text: \(text)")
                }
            } else {
                print("📥 Received binary: \(data.count) bytes")
            }

            do {
                let messageWrapper = try JSONDecoder().decode(WebSocketClient.MessageWrapper.self, from: data)
                self?.handleMessage(messageWrapper, from: clientId)
            } catch let error {
                print("❌ Receive decode error: \(error)")
            }
        }
    }
    
    private func handleMessage(_ messageWrapper: WebSocketClient.MessageWrapper, from clientId: UUID) {
        switch messageWrapper.type {
        case .actionable:
            break
        case .actionables:
            let msg = try! JSONDecoder().decode(WebSocketClient.MessageActionables.self, from: messageWrapper.payload)
            updateTreePackets(with: msg)
        case .schema:
            break
        }
    }
    
    private func updateTreePackets(with msg: WebSocketClient.MessageActionables) {
        guard let rootId = msg.tree.rootNode?.id else { return }

        if treePackets.isEmpty {
            treePackets.append(TreePacket(tree: msg.tree, actionableIds: msg.actionableIds))
            treePacketsLUT[rootId] = treePackets.count - 1
            return
        }

        guard let newTreeIds = retrieveAllIds(tree: msg.tree) else { return }
        let newSet = Set(newTreeIds)

        var foundOldSet = false

        for treePacket in treePackets {
            guard let oldTreeIds = retrieveAllIds(tree: treePacket.tree) else { continue }
            let oldSet = Set(oldTreeIds)

            if !oldSet.isDisjoint(with: newSet) {
                foundOldSet = true
                if let lookupId = oldSet.first(where: { treePacketsLUT[$0] != nil }),
                   let offset = treePacketsLUT[lookupId] {
                    treePackets[offset] = TreePacket(tree: msg.tree, actionableIds: msg.actionableIds)
                }
            }
        }

        if !foundOldSet {
            treePackets.append(TreePacket(tree: msg.tree, actionableIds: msg.actionableIds))
            treePacketsLUT[rootId] = treePackets.count - 1
        }
    }

    private func retrieveAllIds(tree: Tree) -> [String]? {
        guard let root = tree.rootNode else { return nil }
        return retrieveAllIds(treeItem: root)
    }

    private func retrieveAllIds(treeItem: Node) -> [String] {
        var ids: [String] = [treeItem.id]
        if let children = treeItem.children {
            for child in children {
                ids.append(contentsOf: retrieveAllIds(treeItem: child))
            }
        }
        return ids
    }

    // MARK: - Send Methods
    public func sendIsActionable(_ isActionable: Bool, to clientId: UUID) {
        send(type: .actionable, payload: WebSocketClient.MessageActionable(isActionable: isActionable), to: clientId)
    }

    func sendSelectedIds(_ ids: Set<String>, tree: Tree, to clientId: UUID) {
        send(type: .actionables, payload: WebSocketClient.MessageActionables(tree: tree, actionableIds: ids), to: clientId)
    }

    func sendSchema(_ schemaWrappers: [VibeSchemaWrapper], to clientId: UUID) {
        send(type: .schema, payload: WebSocketClient.MessageSchema(schemaWrappers: schemaWrappers), to: clientId)
    }

    private func send<T: Encodable>(type: WebSocketClient.MessageType, payload: T, to clientId: UUID) {
        guard let connection = clients[clientId] else { return }

        guard
            let payloadData = try? JSONEncoder().encode(payload),
            let wrapperData = try? JSONEncoder().encode(WebSocketClient.MessageWrapper(type: type, payload: payloadData))
        else { return }

        // Use text frames if you want compatibility with browser WebSockets
        let opcode: NWProtocolWebSocket.Opcode = .binary
        let metadata = NWProtocolWebSocket.Metadata(opcode: opcode)
        let context = NWConnection.ContentContext(identifier: "WebSocketMessage", metadata: [metadata])

        connection.send(content: wrapperData, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
            if let error = error {
                print("❌ Send error: \(error)")
            } else {
                print("✅ Sent message")
            }
        }))
    }
}

enum VibeWebScript: String, RawRepresentable {
    case initInvokePlayback = "initInvokePlayback"
    case animationsAdd = "animationsAdd"
    case animationsRemove = "animationsRemove"
}

enum VibeWebScriptError: Error {
    case didFailToFind
    case didFailToParse
    case didFailToEval(Error)
    case didFailToParseReturnValue
}

enum VibeSwiftWebsocketError: Error {
    case didFailToEval(Error)
    case serverNil
}

@Observable
final class SelectedActionableIDTracker {
    var selectedActionableIds: Set<String> = []
}

@Observable
public final class EditorModel {
    public var containers: [ActionableContainerAssociater] = []
    public var animations: [ActionableAnimationAssociater] = []
}

public struct ActionableAnimationAssociater: Hashable {
    public let actionableIds: Set<String>
    public let containerId: String
    public let animationId: String
}

public struct ActionableContainerAssociater: Hashable {
    public let actionableIds: Set<String>
    public let containerId: String
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
        animations: [VibeSchema],
        webView: WKWebView,
        coordinator: WKWebViewWrapper.Coordinator,
        selectedActionableIDTracker: SelectedActionableIDTracker,
        contentController: WKUserContentController,
        configuration: WKWebViewConfiguration,
        delegate: AppDelegate
    ) {
        self._url = url
        self._framework = framework
        self.animations = animations
        self.webView = webView
        self.coordinator = coordinator
        self.selectedActionableIDTracker = selectedActionableIDTracker
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
    
//    @State private var server: WebSocketServer? = nil
    @State private var servers: [SetupFlowFramework: WebSocketServer] = [:]

    
    @Binding var url: String
    @Binding var framework: SetupFlowFramework
    let animations: [VibeSchema]
    let webView: WKWebView
    let selectedActionableIDTracker: SelectedActionableIDTracker
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
    
    func executeVibeSwiftWebsocketFunction(schemaWrappers: [VibeSchemaWrapper]) async -> Result<Int, VibeSwiftWebsocketError> {
        guard let server = servers[framework] else {
            return .failure(.serverNil)
        }
        
        for id in server.clients.keys {
            server.sendSchema(schemaWrappers, to: id)
        }
        
        return .success(1)
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
    
    private func runInvokePlayback() async -> Bool {
        let relavantAnimations = Set(editorModel.animations.compactMap({element in
            let containerId = element.containerId
            let actionableIds = element.actionableIds
            
            if let container = editorModel.containers.first(where: { container in
                container.containerId == containerId
            }) {
                return actionableIds.map {
                    InertiaAnimation(actionableId: $0, containerId: container.containerId, containerActionableId: container.actionableIds.first ?? "animation1", animationId: element.animationId)
                }
                .compactMap({$0})
            } else {
                return actionableIds.map {
                    InertiaAnimation(actionableId: $0, containerId: containerId, containerActionableId: "animation1", animationId: element.animationId)
                }
                .compactMap({$0})
            }
            
        })
        .flatMap({$0}))
        
        let animationArgs = relavantAnimations.compactMap { (element: InertiaAnimation) -> VibeSchemaWrapper? in
            guard let schema = self.animations.first(where: {element.containerId == $0.id}) else {
                return nil
            }
            
            guard let container = self.animations.first(where: {$0.id == schema.id}) else {
                return nil
            }
            
            let updateSchema = VibeSchemaWrapper(schema: schema, actionableId: element.actionableId, container: AnimationContainer(actionableId: element.containerActionableId, containerId: container.id), animationId: element.animationId)
            
            return updateSchema
        }
        
        let result = await executeVibeSwiftWebsocketFunction(schemaWrappers: animationArgs)
        
        switch result {
        case .success(let success):
            return success == 1
        case .failure(let failure):
            print(failure)
            return false
        }
    }
    
//    private func invokePlayback() async -> Bool {
//        print(await injectAnimations())
//        
//        let result = await executeVibeWebScript(script: .initInvokePlayback)
//        
//        for id in server.clients.keys {
//            let schemaWrapper = VibeSchemaWrapper(schema: <#T##VibeSchema#>, actionableId: <#T##String#>, container: <#T##AnimationContainer#>, animationId: <#T##String#>)
//            server.sendSchema(<#T##schemaWrappers: [VibeSchemaWrapper]##[VibeSchemaWrapper]#>, to: <#T##UUID#>)
//            server.sendSchema(VibeSchemaWrapper(schema: animations, actionableId: "", container: , animationId: animations.first!.id), to: id)
//        }
//        
//        switch result {
//        case .success(let success):
//            if success == 1 {
//                let playbackSuccess = await runInvokePlayback()
//                return playbackSuccess
//            }
//            
//            return false
//        case .failure(let failure):
//            print(failure)
//            return false
//        }
//    }
    
    private func tapPlay() async {
        print(await runInvokePlayback())
    }
    
    private func determineFocused(newValue: Bool) async {
        // TODO: Does this eneed sometings?
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
    @State private var isMacOSVMLoaded = false
    @State private var isLinuxVMLoaded = false
    @State private var installerFactory: MacOSVMInstalledFactory? = nil
    @State private var isPlaying: Bool = false
    @State private var rowData: [String: [Int]] = [:]
    
    @ViewBuilder
    var treeView: some View {
        if let server = servers[framework] {
            TreeViewContainer(appMode: framework, isFocused: $isFocused, server: server) { ids in
                var localRowData: [String: [Int]] = [:]
                for id in ids {
                    localRowData[id] = [Int]()
                }
                
                self.rowData = localRowData
            }
        }
        
    }
    
    func attachAnimation(id: String, actionableIds: Set<String>) {
        let containers = self.animations
        let animations = self.animations.flatMap({$0.objects})
        
        if let container = containers.first(where: { container in container.id == id }) {
            
            editorModel.containers.append(ActionableContainerAssociater(actionableIds: actionableIds, containerId: container.id))
        } else if let animation = animations.first(where: { animation in animation.id == id }) {
            editorModel.containers.append(ActionableContainerAssociater(actionableIds: Set(["animation1"]), containerId: animation.containerId))
            
            if let server = servers[framework] {
                for treePacket in server.treePackets {
                    for id in treePacket.actionableIds {
                        selectedActionableIDTracker.selectedActionableIds.insert(id)
                    }
                }
                
                editorModel.animations.append(
                    ActionableAnimationAssociater(
                        actionableIds: selectedActionableIDTracker.selectedActionableIds,
                        containerId: animation.containerId,
                        animationId: animation.id
                    )
                )   
            }
        }
    }
    
    var timelineView: some View {
        PanelView(color: colorScheme == .light ? ColorPalette.gray6 : ColorPalette.gray0_5)
            .frame(height: timelineViewHeight)
            .overlay {
                TimelineContainer(isPlaying: $isPlaying, rowData: $rowData)
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
        let fakeDBText = fakeDB
        _exportAnimationFile(text: fakeDBText, url: url)
    }
        
    func _exportAnimationFile(text: String, url: URL) {
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving file: \(error)")
        }
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
                            if let server = try? WebSocketServer(port: 8070) {
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
                                if let server = try? WebSocketServer(port: 8060) {
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
                    .onChange(of: selectedActionableIDTracker.selectedActionableIds) { _, newValue in
                        print(newValue)
                    }
                    .onAppear {
                        frameSize = maxCGSize(lhs: proxy.size, rhs: viewportMinimumSize)
                    }
                    .onChange(of: proxy.size) { oldValue, newValue in
                        frameSize = maxCGSize(lhs: newValue, rhs: viewportMinimumSize)
                    }
                    .onAppear {
                        if servers[.react] == nil {
                            if let server = try? WebSocketServer(port: 8080) {
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
//                                FocusIndicator(isOn: $isFocused)
//                                    .onChange(of: isFocused) { _, newValue in
//                                        for id in server.clients.keys {
//                                            server.sendIsActionable(newValue, to: id)
//                                        }
//                                    }
                                Spacer(minLength: .zero)
                                SettingsIconButton {
                                    showExportPanel()
                                }
                            }
                            
                            if framework == .react {
                                AddressBar(path: url) { newURL in
                                    self.url = newURL
                                }
                                .frame(maxWidth: frameSize?.width)
                                .padding(.top, 24)
                            }

                            AnimationsAvailableColumn(
                                animations: animationsAvailableContents,
                                selected: $selectedAnimation,
                                actionableIds: selectedActionableIDTracker.selectedActionableIds,
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
                        .frame(minHeight: 600)
                        .frame(maxHeight: .infinity)
                        .cornerRadius(topLeft: cornerRadius)
                    }
                    .frame(maxWidth: propertiesViewWidth, maxHeight: .infinity)
                }
            } bottom: {
                timelineView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appColors.backgroundSecondary)
        .environment(\.appColors, appColors)
    }
}
