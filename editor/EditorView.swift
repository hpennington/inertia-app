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

@Observable
final class WebSocketServer {
    let listener: NWListener
    var clients: [UUID: NWConnection] = [:]
    var treePackets: [TreePacket] = []
    var treePacketsLUT: [String: Int] = [:]
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
    
    private func retrieveAllIds(tree: Tree) -> [String]? {
        guard let root = tree.rootNode else {
            return nil
        }
        
        return retrieveAllIds(treeItem: root)
    }

    private func retrieveAllIds(treeItem: Node) -> [String]? {
        var ids: [String] = [treeItem.id]
        
        if let children = treeItem.children {
            for child in children {
                if let childIds = retrieveAllIds(treeItem: child) {
                    ids.append(contentsOf: childIds)
                }
            }
        }
        
        return ids
    }

    private func receiveMessage(on connection: NWConnection, clientId: UUID) {
        connection.receiveMessage { [weak self] (data, context, isComplete, error) in
            if let error = error {
                print("Error receiving message: \(error)")
                self?.clients.removeValue(forKey: clientId)
                return
            }

            if let data = data, !data.isEmpty {
                guard let messageWrapper = try? JSONDecoder().decode(WebSocketClient.MessageWrapper.self, from: data) else {
                    return
                }
                
                switch messageWrapper.type {
                case .actionable:
                    break
                case .actionables:
                    guard let msg = try? JSONDecoder().decode(WebSocketClient.MessageActionables.self, from: messageWrapper.payload) else {
                        return
                    }
                    
                    if let weakSelf = self {
                        if !weakSelf.treePackets.isEmpty {
                            guard let newTreeIds = weakSelf.retrieveAllIds(tree: msg.tree) else {
                                return
                            }

                            var foundOldSet = false

                            treePacketIterator: for treePacket in weakSelf.treePackets {
                                let values = treePacket.tree.nodeMap.values
                                for node in values {
                                    node.tree = treePacket.tree
                                    node.link()
                                }

                                guard let oldTreeIds = weakSelf.retrieveAllIds(tree: treePacket.tree) else {
                                    return
                                }

                                let newSet = Set(newTreeIds)
                                let oldSet = Set(oldTreeIds)

                                var lookupId: String? = nil

                                newSetSearch: for id in oldSet {
                                    if newSet.contains(id) {
                                        foundOldSet = true

                                        for oldId in oldSet {
                                            if weakSelf.treePacketsLUT.keys.contains(oldId) {
                                                lookupId = oldId
                                                break newSetSearch
                                            }
                                        }
                                    }
                                }

                                if foundOldSet {
                                    if let lookupId, let offset = weakSelf.treePacketsLUT[lookupId] {
                                        weakSelf.treePackets[offset] = TreePacket(tree: msg.tree, actionableIds: msg.actionableIds)
                                    }
                                }
                            }

                            if !foundOldSet {
                               weakSelf.treePackets.append(TreePacket(tree: msg.tree, actionableIds: msg.actionableIds))
                               weakSelf.treePacketsLUT[msg.tree.rootNode!.id] = weakSelf.treePackets.count - 1
                           }
                        } else {
                            if let id = msg.tree.rootNode?.id {
                                weakSelf.treePackets.append(TreePacket(tree: msg.tree, actionableIds: msg.actionableIds))
                                weakSelf.treePacketsLUT[id] = weakSelf.treePackets.count - 1
                            }
                        }
                    }
                case .selected:
                    break
                case .schema:
                    break
                }
            }

            self?.receiveMessage(on: connection, clientId: clientId)
        }
    }
    
    public func sendIsActionable(_ isActionable: Bool) {
        guard let connection = clients[clientId] else {
            print("No connection")
            return
        }
        
        let messageItem = WebSocketClient.MessageActionable(isActionable: isActionable)
        guard let data = try? JSONEncoder().encode(messageItem) else {
            return
        }
        
        let messageWrapper = WebSocketClient.MessageWrapper(type: .actionable, payload: data)
        
        guard let wrapperData = try? JSONEncoder().encode(messageWrapper) else {
            return
        }
        sendMessage(wrapperData, to: connection)
    }
    
    func sendSelectedIds(_ ids: Set<String>) {
        guard let connection = clients[clientId] else {
            print("No connection")
            return
        }
        
        let messageItem = WebSocketClient.MessageSelected(selectedIds: ids)
        guard let data = try? JSONEncoder().encode(messageItem) else {
            return
        }
        
        let messageWrapper = WebSocketClient.MessageWrapper(type: .selected, payload: data)
        
        guard let wrapperData = try? JSONEncoder().encode(messageWrapper) else {
            return
        }
        sendMessage(wrapperData, to: connection)
    }
    
    func sendSchema(_ schemaWrappers: [VibeSchemaWrapper]) {
        guard let connection = clients[clientId] else {
            print("No connection")
            return
        }
    
        let message = WebSocketClient.MessageSchema(schemaWrappers: schemaWrappers)
        
        guard let data = try? JSONEncoder().encode(message) else {
            return
        }
        
        let messageWrapper = WebSocketClient.MessageWrapper(type: .schema, payload: data)
        
        guard let wrapperData = try? JSONEncoder().encode(messageWrapper) else {
            return
        }
        sendMessage(wrapperData, to: connection)
    }

    private func sendMessage(_ messageData: Data, to connection: NWConnection) {
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

enum VibeSwiftWebsocketError: Error {
    case didFailToEval(Error)
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

//enum AppMode: Identifiable  {
//    case swiftUI
//    case react
//    case compose
//    
//    var id: Self { self }
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
        animations: [VibeSchema],
        webView: WKWebView,
        contentController: WKUserContentController,
        configuration: WKWebViewConfiguration,
        delegate: AppDelegate
    ) {
        self._url = url
        self._framework = framework
        self.animations = animations
        self.webView = webView
        self.contentController = contentController
        self.configuration = configuration
        self.delegate = delegate
    }
    
//    @State private var appMode: AppMode = .react
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
    @Binding var framework: SetupFlowFramework
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
    
    func executeVibeSwiftWebsocketFunction(schemaWrappers: [VibeSchemaWrapper]) async -> Result<Int, VibeSwiftWebsocketError> {
        server.sendSchema(schemaWrappers)
        return .success(1)
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
    
    private func runInvokePlayback(swift: Bool? = nil) async -> Bool {
        if swift == true {
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
        } else {
            let relavantAnimations = Set(editorModel.animations.compactMap({element in
                let containerId = element.containerId
                let actionableIds = element.actionableIds
                
                if let container = editorModel.containers.first(where: { container in
                    container.containerId == containerId
                }) {
                    return actionableIds.map {
                        InertiaAnimation(actionableId: $0, containerId: container.containerId, containerActionableId: container.actionableIds.first ?? "body-vibe-id", animationId: element.animationId)
                    }
                    .compactMap({$0})
                } else {
                    return actionableIds.map {
                        InertiaAnimation(actionableId: $0, containerId: containerId, containerActionableId: "body-vibe-id", animationId: element.animationId)
                    }
                    .compactMap({$0})
                }
                
            })
            .flatMap({$0}))
            
            let animationArgs = relavantAnimations.compactMap { (element: InertiaAnimation) -> String? in
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
        if framework == .swiftUI {
            print(await runInvokePlayback(swift: true))
        } else if framework == .react {
            let removeSuccess = await cleanAnimations()
            
            if removeSuccess {
                let invokeSuccess = await invokePlayback()
            }
        }
    }
    
    private func determineFocused(newValue: Bool) async {
        if newValue {
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
    @State private var isPlaying: Bool = false
    @State private var rowData: [String: [Int]] = [:]
    
    @ViewBuilder
    var treeView: some View {
        TreeViewContainer(appMode: framework, isFocused: $isFocused, server: $server) { ids in
            var localRowData: [String: [Int]] = [:]
            for id in ids {
                localRowData[id] = [Int]()
            }
            
            self.rowData = localRowData
        }
    }
    
    func attachAnimation(id: String, actionableIds: Set<String>) {
        let containers = self.animations
        let animations = self.animations.flatMap({$0.objects})
        
        if let container = containers.first(where: { container in container.id == id }) {
            
            editorModel.containers.append(ActionableContainerAssociater(actionableIds: actionableIds, containerId: container.id))
        } else if let animation = animations.first(where: { animation in animation.id == id }) {
            if framework == .swiftUI {
                editorModel.containers.append(ActionableContainerAssociater(actionableIds: Set(["animation1"]), containerId: animation.containerId))
                for treePacket in server.treePackets {
                    for id in treePacket.actionableIds {
                        selectedActionabeIDTracker.selectedActionableIds.insert(id)
                    }
                }
                
                editorModel.animations.append(
                    ActionableAnimationAssociater(
                        actionableIds: selectedActionabeIDTracker.selectedActionableIds,
                        containerId: animation.containerId,
                        animationId: animation.id
                    )
                )
            } else if framework == .react {
                editorModel.containers.append(ActionableContainerAssociater(actionableIds: Set(["body-vibe-id"]), containerId: animation.containerId))
                editorModel.animations.append(ActionableAnimationAssociater(actionableIds: actionableIds, containerId: animation.containerId, animationId: animation.id))
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
                        
                    case .compose:
                        Text("Coming soon")
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
                                Text("Web")
                                    .tag(SetupFlowFramework.react)
                                Text("iOS")
                                    .tag(SetupFlowFramework.swiftUI)
                                Text("Android")
                                    .tag(SetupFlowFramework.compose)
                            } label: {
                                EmptyView()
                            }
                            .pickerStyle(.segmented)
                            .padding(.vertical)
                            
                            HStack() {
                                FocusIndicator(isOn: $isFocused)
                                    .onChange(of: isFocused) { _, newValue in
                                        server.sendIsActionable(newValue)
                                    }
                                Spacer(minLength: .zero)
                                SettingsIconButton {
                                    showExportPanel()
                                }
                            }

                            AnimationsAvailableColumn(
                                animations: animationsAvailableContents,
                                selected: $selectedAnimation,
                                actionableIds: $selectedActionabeIDTracker.wrappedValue.selectedActionableIds,
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
