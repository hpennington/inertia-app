//
// Vibe SwiftUI animation library
// Created by Hayden Pennington
//
// Copyright (c) 2024 Vector Studio. All rights reserved.
//

import SwiftUI

public typealias VibeID = String

public class Node: Identifiable, Hashable, Codable, Equatable, CustomStringConvertible {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public let id: String
    public weak var parent: Node?
    public var children: [Node]? = []
    public weak var tree: Tree? = nil
    
    init(id: String, parentId: String? = nil) {
        self.id = id
        self.parentId = parentId
    }
    
    func addChild(_ child: Node) {
        child.parent = self
        child.parentId = self.id
        children?.append(child)
    }
    
    public var description: String {
        "{id: \(id), parentId: \(parentId), parent.id: \(parent?.id), children: \(children?.map {$0.id})}"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parentId"
        case children
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
        children = try container.decodeIfPresent([Node].self, forKey: .children)
    }
    
    private var parentId: String? = nil
    
    public func link() {
        if let parentId {
            self.parent = tree!.nodeMap[parentId]
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(parentId, forKey: .parentId) // Encode only the parent's ID
        try container.encode(children, forKey: .children)
    }
}

public class Tree: Identifiable, Hashable, Codable, CustomStringConvertible, Equatable {
    public static func == (lhs: Tree, rhs: Tree) -> Bool {
        return lhs.rootNode == rhs.rootNode
    }
    
    required public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.nodeMap = try container.decode([String : Node].self, forKey: .nodeMap)
        self.rootNode = try container.decodeIfPresent(Node.self, forKey: .rootNode)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case nodeMap
        case rootNode
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.nodeMap, forKey: .nodeMap)
        try container.encodeIfPresent(self.rootNode, forKey: .rootNode)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(nodeMap)
    }
    
    public let id: String
    
    init(id: String) {
        self.id = id
    }
    
    public var nodeMap: [String: Node] = [:]
    public var rootNode: Node?

    func addRelationship(id: String, parentId: String?, parentIsContainer: Bool) {
        // Get or create the current node
        let currentNode = nodeMap[id] ?? {
            let newNode = Node(id: id, parentId: parentId)
            nodeMap[id] = newNode
            return newNode
        }()

        if let parentId = parentId {
            // Get or create the parent node
            let parentNode = nodeMap[parentId] ?? {
                let newNode = Node(id: parentId)
                nodeMap[parentId] = newNode
                return newNode
            }()

            if parentIsContainer {
                // If explicitly marked as root, set it as the root node
                // Establish parent-child relationship
                parentNode.addChild(currentNode)
                rootNode = parentNode
            } else {
                parentNode.addChild(currentNode)
                if rootNode == nil && parentNode.parent == nil {
                    rootNode = parentNode
                }
            }
        }
    }
    
    public var description: String {
        "treeId: \(id) root: \(rootNode)"
    }
}


private struct VibeDataModelKey: EnvironmentKey {
    static let defaultValue: InertiaDataModel? = nil
}

private struct InertiaParentIDKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

private struct InertiaContainerIdKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

private struct IsInertiaContainerKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var vibeDataModel: InertiaDataModel? {
        get { self[VibeDataModelKey.self] }
        set { self[VibeDataModelKey.self] = newValue }
    }
    
    var inertiaParentID: String? {
        get {
            self[InertiaParentIDKey.self]
        }
        set {
            self[InertiaParentIDKey.self] = newValue
        }
    }
    
    var inertiaContainerId: String? {
        get {
            self[InertiaContainerIdKey.self]
        }
        set {
            self[InertiaContainerIdKey.self] = newValue
        }
    }
    
    var isInertiaContainer: Bool {
        get {
            self[IsInertiaContainerKey.self]
        }
        set {
            self[IsInertiaContainerKey.self] = newValue
        }
    }
}

//public protocol VibeDataModel: Equatable {
//    public var objects: [VibeID: VibeShape] { get set }
//    public var states: [VibeID: VibeAnimationState] { get set }
//}

public final class VibeViewModel: ObservableObject {
//    public let id: VibeID
    @Published public var device: MTLDevice = MTLCreateSystemDefaultDevice()!
    public var layerOwner: [Int: VibeID] = [:]
    
    public init() {
    }
    
    public func updateState(id: VibeID, isCancelled: Bool? = nil, trigger: Bool? = nil) {
//        if let currentState = self.dataModel.states[id] {
//            if let isCancelled, let trigger {
//                self.dataModel.states.updateValue(VibeAnimationState(id: currentState.id, trigger: trigger, isCancelled: isCancelled), forKey: currentState.id)
//            } else if let isCancelled {
//                self.dataModel.states.updateValue(VibeAnimationState(id: currentState.id, trigger: currentState.trigger, isCancelled: isCancelled), forKey: currentState.id)
//            } else if let trigger {
//                self.dataModel.states.updateValue(VibeAnimationState(id: currentState.id, trigger: trigger, isCancelled: currentState.isCancelled), forKey: currentState.id)
//            }
//        }
    }
    
    public func trigger(_ id: VibeID) {
        self.updateState(id: id, trigger: true)
    }

    public func cancel(_ id: VibeID) {
        self.updateState(id: id, isCancelled: true)
    }

    public func restart(_ id: VibeID) {
        self.updateState(id: id, isCancelled: false)
    }
}

#if os(iOS)
import UIKit
public struct VibeViewRepresentable: UIViewRepresentable {
    public typealias UIViewType = UIView
    
    let view: () -> UIViewType
    
    public func makeUIView(context: Context) -> UIViewType {
        let view = view()
        view.isOpaque = false
        view.backgroundColor = .clear
        return view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
#else
import AppKit
public struct VibeViewRepresentable: NSViewRepresentable {
    public typealias NSViewType = NSView
    
    let view: () -> NSViewType
    
    public func makeNSView(context: Context) -> NSViewType {
        let view = view()
//        view.isOpaque = false
//        view.backgroundColor = .clear
        return view
    }
    
    public func updateNSView(_ uiView: NSViewType, context: Context) {
        
    }
}
#endif

@Observable
public final class InertiaDataModel {
    public let containerId: VibeID
    public var vibeSchema: VibeSchema
    public var tree: Tree
    public var actionableIds: Set<String>
    
    public var states: [VibeID: VibeAnimationState]
    public var actionableIdToAnimationIdMap: [String: String] = [:]
    public var isActionable: Bool = false
    
    public init(containerId: VibeID, vibeSchema: VibeSchema, tree: Tree, actionableIds: Set<String>) {
        self.containerId = containerId
        self.vibeSchema = vibeSchema
        self.tree = tree
        self.actionableIds = actionableIds
        self.states = [:]
    }
}

public struct InertiaContainer<Content: View>: View {
    let bundle: Bundle
    let id: VibeID
    let hierarchyId: String
    @State private var vibeDataModel: InertiaDataModel
    @ViewBuilder let content: () -> Content
    
    public init(
        bundle: Bundle = Bundle.main,
        id: VibeID,
        hierarchyId: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.bundle = bundle
        self.id = id
        self.hierarchyId = hierarchyId
        self.content = content
        
        // TODO: - Solve error handling when file is missing or schema is wrong
        if let url = bundle.url(forResource: id, withExtension: "json") {
            let schemaText = try! String(contentsOf: url, encoding: .utf8)
            if let data = schemaText.data(using: .utf8),
               let schema = decodeVibeSchema(json: data) {
                self._vibeDataModel = State(wrappedValue: InertiaDataModel(containerId: id, vibeSchema: schema, tree: Tree(id: id), actionableIds: Set()))
            } else {
                fatalError()
            }
//            else {
//                print("Failed to parse the schema")
//                fatalError()
////                self._vibeDataModel = State(wrappedValue: VibeDataModel(containerId: id))
//            }
        } else {
            NSLog("[INERTIA_LOG]:  Failed to parse the vibe file")
            fatalError()
//            self._vibeDataModel = State(wrappedValue: VibeDataModel(containerId: id))
        }
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                content()
                    .environment(\.inertiaParentID, hierarchyId)
                    .environment(\.vibeDataModel, self.vibeDataModel)
                    .environment(\.isInertiaContainer, true)
                    .environment(\.inertiaContainerSize, proxy.size)
                    .environment(\.inertiaContainerId, hierarchyId)
                    .coordinateSpace(.named(hierarchyId))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .border(.green)
        }
    }
}

public class WebSocketClient {
    var task: URLSessionWebSocketTask? = nil
    var isConnected: Bool = false
    public var messageReceived: ((_ selectedIds: Set<String>) -> Void)? = nil
    public var messageReceivedSchema: ((_ schemas: [VibeSchemaWrapper]) -> Void)? = nil
    public var messageReceivedIsActionable: ((_ isActionable: Bool) -> Void)? = nil
    static let shared = WebSocketClient()

    init() {

    }
    
    func connect(uri: URL) {
        self.task = URLSession.shared.webSocketTask(with: uri)
        self.task?.resume()
        isConnected = true
    }
    
    public enum MessageType: Codable {
        case actionable
        case actionables
        case selected
        case schema
    }
    
    public struct MessageWrapper: Codable {
        public let type: MessageType
        public let payload: Data
        
        public init(type: MessageType, payload: Data) {
            self.type = type
            self.payload = payload
        }
    }
    
    public struct MessageActionables: Codable {
        public let tree: Tree
        public let actionableIds: Set<String>
        
        public init(tree: Tree, actionableIds: Set<String>) {
            self.tree = tree
            self.actionableIds = actionableIds
        }
    }
    
    public struct MessageActionable: Codable {
        public let isActionable: Bool
        
        public init(isActionable: Bool) {
            self.isActionable = isActionable
        }
    }
    
    public struct MessageSelected: Codable {
        public let selectedIds: Set<String>
        
        public init(selectedIds: Set<String>) {
            self.selectedIds = selectedIds
        }
    }
    
    public struct MessageSchema: Codable {
        public let schemaWrappers: [VibeSchemaWrapper]
        
        public init(schemaWrappers: [VibeSchemaWrapper]) {
            self.schemaWrappers = schemaWrappers
        }
    }
    
    func sendMessage(_ message: MessageActionables) {
        do {
            guard let jsonData = try? JSONEncoder().encode(message) else {
                print("Error: Could not encode JSON to data")
                 return
            }
            
            let messageWrapper = MessageWrapper(type: .actionables, payload: jsonData)
            let messageWrapperData = try JSONEncoder().encode(messageWrapper)

            let messageData = URLSessionWebSocketTask.Message.data(messageWrapperData)
            task?.send(messageData) { error in
                if let error = error {
                    print("Error sending message: \(error)")
                } else {
                    print("Message sent: \(messageData)")
                }
                
                // Begin receiving responses
                if let task = self.task {
                    self.receiveMessage(task: task)
                }
            }
            
        } catch {
            print("Error encoding data: \(error)")
        }
    }
    
    func sendMessage(_ message: MessageSelected) {
        do {
            guard let jsonData = try? JSONEncoder().encode(message) else {
                print("Error: Could not encode JSON to data")
                 return
            }
            
            let messageWrapper = MessageWrapper(type: .selected, payload: jsonData)
            let messageWrapperData = try JSONEncoder().encode(messageWrapper)

            let messageData = URLSessionWebSocketTask.Message.data(messageWrapperData)
            task?.send(messageData) { error in
                if let error = error {
                    print("Error sending message: \(error)")
                } else {
                    print("Message sent: \(messageData)")
                }
                
                // Begin receiving responses
                if let task = self.task {
                    self.receiveMessage(task: task)
                }
            }
            
        } catch {
            print("Error encoding data: \(error)")
        }
    }
    
    func sendMessage(_ message: MessageSchema) {
        do {
            guard let jsonData = try? JSONEncoder().encode(message) else {
                print("Error: Could not encode JSON to data")
                 return
            }
            
            let messageWrapper = MessageWrapper(type: .schema, payload: jsonData)
            guard let messageWrapperData = try? JSONEncoder().encode(messageWrapper) else {
                return
            }

            let messageData = URLSessionWebSocketTask.Message.data(messageWrapperData)
            task?.send(messageData) { error in
                if let error = error {
                    print("Error sending message: \(error)")
                } else {
                    print("Message sent: \(messageData)")
                }
                
                // Begin receiving responses
                if let task = self.task {
                    self.receiveMessage(task: task)
                }
            }
            
        } catch {
            print("Error encoding data: \(error)")
        }
    }
    
    func receiveMessage(task: URLSessionWebSocketTask) {
        task.receive { result in
            switch result {
            case .failure(let error):
                print("Error receiving message: \(error)")
                task.cancel(with: .normalClosure, reason: nil)
            case .success(let message):
                switch message {
                case .data(let data):
                    
                    guard let messageWrapper = try? JSONDecoder().decode(WebSocketClient.MessageWrapper.self, from: data) else {
                        return
                    }
                    
                    switch messageWrapper.type {
                    case .actionable:
                        guard let actionableMessage = try? JSONDecoder().decode(WebSocketClient.MessageActionable.self, from: messageWrapper.payload) else {
                            return
                        }
                        
                        NSLog("[INERTIA_LOG]:  Received message (data): \(actionableMessage)")
                        self.messageReceivedIsActionable?(actionableMessage.isActionable)
                    case .actionables:
                        fatalError()
                    case .schema:
                        guard let schemaMessage = try? JSONDecoder().decode(WebSocketClient.MessageSchema.self, from: messageWrapper.payload) else {
                            return
                        }
                        
                        NSLog("[INERTIA_LOG]:  Received message (data): \(schemaMessage)")
                        self.messageReceivedSchema?(schemaMessage.schemaWrappers)
                    case .selected:
                        guard let selectedIdsMessage = try? JSONDecoder().decode(WebSocketClient.MessageSelected.self, from: messageWrapper.payload) else {
                            return
                        }
                        
                        NSLog("[INERTIA_LOG]:  Received message (data): \(selectedIdsMessage)")
                        self.messageReceived?(selectedIdsMessage.selectedIds)
                    }
                case .string(let text):
                    fatalError()
                    print("Received message (text): \(text)")
                @unknown default:
                    print("Received an unknown message type.")
                }
            }
            
            self.receiveMessage(task: task)
        }
    }
}

func getHostIPAddressFromResolvConf() -> String? {
    guard let resolvContents = try? String(contentsOfFile: "/etc/resolv.conf") else {
        print("Failed to read /etc/resolv.conf")
        return nil
    }
    
    let lines = resolvContents.components(separatedBy: "\n")
    var potentialIPs = [String]()
    
    for line in lines {
        if line.starts(with: "nameserver") {
            let components = line.components(separatedBy: " ")
            if components.count > 1 {
                let ipAddress = components[1].trimmingCharacters(in: .whitespaces)
                
                // Simple IP address validation
                if isValidIPAddress(ipAddress) {
                    potentialIPs.append(ipAddress)
                }
            }
        }
    }
    
    if let firstValidIP = potentialIPs.first {
        return firstValidIP
    } else {
        print("No valid IP addresses found in /etc/resolv.conf")
        return nil
    }
}

// Helper function to validate an IPv4 address format
func isValidIPAddress(_ ipAddress: String) -> Bool {
    let parts = ipAddress.split(separator: ".").map { Int($0) }
    guard parts.count == 4, parts.allSatisfy({ $0 != nil && $0! >= 0 && $0! <= 255 }) else {
        return false
    }
    return true
}

struct ParentPath: PreferenceKey {
    static var defaultValue: [String]? = nil
    
    static func reduce(value: inout [String]?, nextValue: () -> [String]?) {
        value? += nextValue() ?? []
    }
}

let manager = WebSocketClient.shared

struct VibeCanvasSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var inertiaContainerSize: CGSize {
        get { self[VibeCanvasSizeKey.self] }
        set { self[VibeCanvasSizeKey.self] = newValue }
    }
}

struct InertiaActionable<Content: View>: View {
    let content: Content
    
    init(content: Content) {
        self.content = content
    }
    
    var body: some View {
        content
    }
}

fileprivate var hierarchyIdIndexMap: [String: Int] = [:]

struct InertiaEditable<Content: View>: View {
    @State private var dragOffset: CGSize = .zero
    @State private var animation: VibeAnimationSchema? = nil
    @State private var contentSize: CGSize = .zero
    @State private var vm = VibeViewModel()
    @State private var myHierarchyId: String? = nil
    @State private var hasBeenInitialized = false
    
    let id: String
    let content: Content
    
    init(_ id: String, content: Content) {
        self.id = id
        self.content = content
        
//        if !hasBeenInitialized {
//            let index = nextIndex(id)
//            self.myHierarchyId = id + "--\(index)"
//        }
//        
//        self.hasBeenInitialized = true
    }
    
    private func retrieveNextIndex(_ id: String) -> Int {
        if let index = hierarchyIdIndexMap[id] {
            hierarchyIdIndexMap[id] = index + 1
            return index + 1
        } else {
            hierarchyIdIndexMap[id] = .zero
            return .zero
        }
    }
    
    @Environment(\.vibeDataModel) var vibeDataModel
    @Environment(\.inertiaParentID) var inertiaParentID
    @Environment(\.inertiaContainerId) var inertiaContainerId
    @Environment(\.isInertiaContainer) var isInertiaContainer
    @Environment(\.inertiaContainerSize) var inertiaContainerSize: CGSize
    
    var hierarchyId: String? {
        guard let myHierarchyId else {
            let value = self.id + "--\(retrieveNextIndex(id))"
            self.myHierarchyId = value
            return self.myHierarchyId
        }
        
        return self.myHierarchyId
    }
    
    var showSelectedBorder: Bool {
        guard let vibeDataModel else {
            return false
        }
        
        guard let hierarchyId else {
            return false
        }

        return vibeDataModel.actionableIds.contains(hierarchyId)
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if vibeDataModel?.isActionable == true {
                    dragOffset = value.translation
                }
                
            }
            .onEnded { value in
                if vibeDataModel?.isActionable == true {
                    dragOffset = value.translation
                }
            }
    }
    
    var wrappedContent: some View {
        ZStack(alignment: .center) {
            content
//                .modifier(BindableSize(size: $contentSize))
        }
        .onTapGesture {
            print("tapped \(content)")
            guard let vibeDataModel else {
                return
            }
            
            guard vibeDataModel.isActionable else {
                return
            }
            
            guard let hierarchyId else {
                return
            }

            if vibeDataModel.actionableIds.contains(hierarchyId) {
                vibeDataModel.actionableIds.remove(hierarchyId)
            } else {
                vibeDataModel.actionableIds.insert(hierarchyId)
            }
            
            if let ip = getHostIPAddressFromResolvConf() {
                let uri = URL(string: "ws://\(ip):8060")!
//                    let data: [String: Tree?] = ["tree": vibeDataModel?.tree]
                
                NSLog("[INERTIA_LOG]: Tapped: Starting to send data...")
                
                if !manager.isConnected {
                    manager.connect(uri: uri)
                }
                
                let tree = vibeDataModel.tree
                let actionableIds = vibeDataModel.actionableIds
                let message = WebSocketClient.MessageActionables(tree: tree, actionableIds: actionableIds)
                manager.sendMessage(message)
            }
        }
        .overlay {
            if showSelectedBorder && vibeDataModel?.isActionable ?? false{
                Rectangle()
                    .stroke(Color.green)
            }
        }
        .offset(dragOffset)
        .gesture(dragGesture)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        let frame = CGRect(origin: .zero, size: inertiaContainerSize)
        let device = vm.device
        NSLog("[INERTIA_LOG]:  enter backgroundView")
        guard let vibeDataModel else {
            return AnyView(EmptyView())
        }
                
        let object = vibeDataModel.vibeSchema.objects.first(where: { element in
            element.objectType == .shape
        })
        
        NSLog("[INERTIA_LOG]:  enter object")
        guard let currentViewZIndex = object?.zIndex else {
            return AnyView(EmptyView())
        }
        NSLog("[INERTIA_LOG]:  enter currentViewZIndex")
        guard currentViewZIndex != .zero else {
            return AnyView(EmptyView())
        }
        
//        if vm.layerOwner[currentViewZIndex - 1] == nil {
//            NSLog("[INERTIA_LOG]:  enter layerOwnder 1")
//            vm.layerOwner[currentViewZIndex - 1] = object?.id
//        } else if vm.layerOwner[currentViewZIndex - 1] != object?.id {
//            NSLog("[INERTIA_LOG]:  enter layerOwnder 2")
//            return AnyView(EmptyView())
//        }
        
//        let zUnderObjects = vibeDataModel.vibeSchema.objects.filter({$0.objectType == .shape && $0.zIndex == currentViewZIndex - 1})
        let zUnderObjects = vibeDataModel.vibeSchema.objects.filter({$0.objectType == .shape})

        if !zUnderObjects.isEmpty {
            NSLog("[INERTIA_LOG]:  enter zUnderObjects")
            let uiview = TouchForwardingComponent(interactive: false, component: {
                VibeViewRepresentable {
                    let vertices = zUnderObjects.flatMap {
                        let node = TriangleNode(
                            id: $0.id,
                            animationValues: .zero,
                            zIndex: $0.zIndex,
                            size: $0.width,
                            center: $0.position,
                            color: CGColor(red: $0.color[0], green: $0.color[1], blue: $0.color[2], alpha: $0.color[3])
                        )
                        
                        return node.vertices
                    }
                    
                    return VertexRenderer(frame: frame, device: device, vertices: vertices)
                }.frame(width: inertiaContainerSize.width, height: inertiaContainerSize.height)}, frame: frame)
            
            
            return AnyView(
                VibeViewRepresentable {
                    return uiview
                }
            )
        } else {
            NSLog("[INERTIA_LOG]:  enter EmptyView")
            return AnyView(EmptyView())
        }
    }
    
    var body: some View {
        //        GeometryReader { rootProxy in
        Group {
            if let animation = animation ?? getAnimation {
                wrappedContent
                    .keyframeAnimator(initialValue: animation.initialValues, content: { contentView, values in
                        contentView
                            .scaleEffect(values.scale)
                            .rotationEffect(Angle(degrees: values.rotate), anchor: .topLeading)
                            .rotationEffect(Angle(degrees: values.rotateCenter), anchor: .center)
                            .offset(x: values.translate.width * inertiaContainerSize.width / 2, y: values.translate.height * inertiaContainerSize.height / 2)
                            .opacity(values.opacity)
                    }, keyframes: { _ in
                        KeyframeTrack {
                            for keyframe in animation.keyframes {
                                CubicKeyframe(keyframe.values, duration: keyframe.duration)
                            }
                        }
                    })
                    .onAppear {
                        self.animation = animation
                    }
                    .onChange(of: self.hierarchyId) { _, _ in
                        self.animation = getAnimation
                    }
                    .onChange(of: self.hasBeenInitialized) { _, _ in
                        self.animation = getAnimation
                    }
            } else {
                wrappedContent
                    .onChange(of: self.hierarchyId) { _, _ in
                        self.animation = getAnimation
                    }
                    .onChange(of: self.hasBeenInitialized) { _, _ in
                        self.animation = getAnimation
                    }
            }
        }
    //            .frame(minWidth: contentSize.width, minHeight: contentSize.height)

        .background(
            GeometryReader { proxy in
                backgroundView
                    .frame(width: inertiaContainerSize.width, height: inertiaContainerSize.height)
                    .offset(x: -proxy.frame(in: .named(inertiaContainerId)).origin.x, y: -proxy.frame(in: .named(inertiaContainerId)).origin.y)
            }
        )
        .environment(\.inertiaParentID, hierarchyId)
        .environment(\.isInertiaContainer, false)
        .buttonStyle(.plain)
        .onAppear {
            if let ip = getHostIPAddressFromResolvConf() {
                let uri = URL(string: "ws://\(ip):8060")!
    //                    let data: [String: Tree?] = ["tree": vibeDataModel?.tree]
                
                NSLog("[INERTIA_LOG]: Starting to send data 2 (setup)...")
                
                if !manager.isConnected {
                    manager.connect(uri: uri)
                }
                
                manager.messageReceived = handleMessage
                manager.messageReceivedSchema = handleMessageSchema
                manager.messageReceivedIsActionable = handleMessageActionable
            }
            
        }
        .onChange(of: vibeDataModel?.tree, { oldValue, newValue in
            if let tree = newValue {
                for node in tree.nodeMap.values {
                    node.tree = tree
                    node.link()
                }
            }
        })
        .onAppear {
            guard let hierarchyId else {
                NSLog("onAppear hierarchyId is nil")
                return
            }
            //
            print("onAppear: \(hierarchyId)")
        }
        .onChange(of: self.hierarchyId, { oldValue, newValue in
            guard let hierarchyId = newValue else {
                return
            }
            
            print("onAppear: \(hierarchyId)")
            NSLog("[INERTIA_LOG]:  adding relationship: hierarchyId: \(hierarchyId) inertiaParentID: \(inertiaParentID), isInertiaContainer: \(isInertiaContainer)")
            
            vibeDataModel?.tree.addRelationship(id: hierarchyId, parentId: inertiaParentID, parentIsContainer: isInertiaContainer)
            if let tree = vibeDataModel?.tree {
                for node in tree.nodeMap.values {
                    node.tree = tree
                    node.link()
                }
            }
            
            if let ip = getHostIPAddressFromResolvConf() {
                let uri = URL(string: "ws://\(ip):8060")!
    //                    let data: [String: Tree?] = ["tree": vibeDataModel?.tree]
                
                NSLog("[INERTIA_LOG]: Starting to send data 2...")
                
                if !manager.isConnected {
                    manager.connect(uri: uri)
                }
                
                if let tree = vibeDataModel?.tree, let actionableIds = vibeDataModel?.actionableIds {
                    let message = WebSocketClient.MessageActionables(tree: tree, actionableIds: actionableIds)
                    manager.sendMessage(message)
                }
            }
        })
        .onDisappear {
            if let zIndex = vibeDataModel?.vibeSchema.objects.first(where: { element in
                element.objectType == .shape
            })?.zIndex {
                vm.layerOwner[zIndex]?.removeAll()
            }
        }
    }
    
    var getAnimation: VibeAnimationSchema? {
        guard let vibeDataModel else {
            NSLog("[INERTIA_LOG]:  vibeDataModel is nil")
            return nil
        }
        
        guard let hierarchyId else {
            NSLog("[INERTIA_LOG]:  getAnimation hierarchyId is nil")
            return nil
        }

        if vibeDataModel.actionableIds.contains(hierarchyId) {
            guard let animationId = vibeDataModel.actionableIdToAnimationIdMap[hierarchyId] else {
                NSLog("[INERTIA_LOG]:  animationId is nil")
                return nil
            }
            NSLog("[INERTIA_LOG]:  hierarchyId: \(hierarchyId) animationId: \(animationId)")
            let animation = vibeDataModel.vibeSchema.objects.first(where: { $0.animation.id == animationId })?.animation
            
            if let animation {
                return animation
            } else {
                NSLog("\(vibeDataModel.vibeSchema.objects)")
                NSLog("[INERTIA_LOG]:  animation is nil")
                return nil
            }
        }
        
        NSLog("[INERTIA_LOG]:  animation nil at end")
        return nil
        
    }
    
    func handleMessage(selectedIds: Set<String>) {
        vibeDataModel?.actionableIds = selectedIds
    }
    
    func handleMessageSchema(schemaWrappers: [VibeSchemaWrapper]) {
        for schemaWrapper in schemaWrappers {
            if schemaWrapper.container.containerId == vibeDataModel?.containerId {
                vibeDataModel?.vibeSchema = schemaWrapper.schema
                vibeDataModel?.actionableIdToAnimationIdMap[schemaWrapper.actionableId] = schemaWrapper.animationId
                NSLog("[INERTIA_LOG]:  animationId: \(schemaWrapper.animationId)")
            }
        }
    }
    
    func handleMessageActionable(isActionable: Bool) {
        vibeDataModel?.isActionable = isActionable
    }
}

public struct VibeAnimationState: Identifiable, Equatable, Codable {
    public let id: VibeID
    public let trigger: Bool?
    public let isCancelled: Bool
    
    public init(id: VibeID, trigger: Bool? = nil, isCancelled: Bool = false) {
        self.id = id
        self.trigger = trigger
        self.isCancelled = isCancelled
    }
}

public struct AnimationContainer: Codable, Hashable {
    public let actionableId: String
    public let containerId: String
    
    public init(actionableId: String, containerId: String) {
        self.actionableId = actionableId
        self.containerId = containerId
    }
}

public struct InertiaAnimation: Codable, Hashable {
    public let actionableId: String
    public let containerId: String
    public let containerActionableId: String
    public let animationId: String
    
    public init(actionableId: String, containerId: String, containerActionableId: String, animationId: String) {
        self.actionableId = actionableId
        self.containerId = containerId
        self.containerActionableId = containerActionableId
        self.animationId = animationId
    }
}

public struct VibeSchemaWrapper: Codable {
    public let schema: VibeSchema
    public let actionableId: String
    public let container: AnimationContainer
    public let animationId: String
    
    public init(schema: VibeSchema, actionableId: String, container: AnimationContainer, animationId: String) {
        self.schema = schema
        self.actionableId = actionableId
        self.container = container
        self.animationId = animationId
    }
}

extension View {
    public func inertiaEditable(_ hierarchyId: String) -> some View {
        InertiaEditable(hierarchyId, content: self)
    }
    
    public func inertia() -> some View {
        InertiaActionable(content: self)
    }
    
    public func inertiaContainer(id: VibeID, hierarchyId: String) -> some View {
        InertiaContainer(id: id, hierarchyId: hierarchyId) {
            self
        }
    }
}

public struct VibeAnimationValues: VectorArithmetic, Animatable, Codable, Equatable {
    public static var zero = VibeAnimationValues(scale: .zero, translate: .zero, rotate: .zero, rotateCenter: .zero, opacity: .zero)
    
    public var scale: CGFloat
    public var translate: CGSize
    public var rotate: CGFloat
    public var rotateCenter: CGFloat
    public var opacity: CGFloat

    public var magnitudeSquared: Double {
        let translateMagnitude = Double(translate.width * translate.width + translate.height * translate.height)
        return Double(scale * scale) + translateMagnitude + Double(rotate * rotate) + Double(rotateCenter * rotateCenter) + Double(opacity * opacity)
    }

    public mutating func scale(by rhs: Double) {
        scale *= CGFloat(rhs)
        translate.width *= CGFloat(rhs)
        translate.height *= CGFloat(rhs)
        rotate *= CGFloat(rhs)
        rotateCenter *= CGFloat(rhs)
        opacity *= CGFloat(rhs)
    }

    public static func += (lhs: inout VibeAnimationValues, rhs: VibeAnimationValues) {
        lhs.scale += rhs.scale
        lhs.translate.width += rhs.translate.width
        lhs.translate.height += rhs.translate.height
        lhs.rotate += rhs.rotate
        lhs.rotateCenter += rhs.rotateCenter
        lhs.opacity += rhs.opacity
    }

    public static func -= (lhs: inout VibeAnimationValues, rhs: VibeAnimationValues) {
        lhs.scale -= rhs.scale
        lhs.translate.width -= rhs.translate.width
        lhs.translate.height -= rhs.translate.height
        lhs.rotate -= rhs.rotate
        lhs.rotateCenter -= rhs.rotateCenter
        lhs.opacity -= rhs.opacity
    }

    public static func * (lhs: VibeAnimationValues, rhs: Double) -> VibeAnimationValues {
        var result = lhs
        result.scale(by: rhs)
        return result
    }

    public static func + (lhs: VibeAnimationValues, rhs: VibeAnimationValues) -> VibeAnimationValues {
        var result = lhs
        result += rhs
        return result
    }

    public static func - (lhs: VibeAnimationValues, rhs: VibeAnimationValues) -> VibeAnimationValues {
        var result = lhs
        result -= rhs
        return result
    }
}

public struct VibeAnimationKeyframe: Identifiable, Codable, Equatable {
    public let id: VibeID
    public let values: VibeAnimationValues
    public let duration: CGFloat
    
    public init(id: VibeID, values: VibeAnimationValues, duration: CGFloat) {
        self.id = id
        self.values = values
        self.duration = duration
    }
    
    public static func == (lhs: VibeAnimationKeyframe, rhs: VibeAnimationKeyframe) -> Bool {
        lhs.id == rhs.id &&
        lhs.values == rhs.values &&
        lhs.duration == rhs.duration
    }
}

public enum VibeObjectType: String, Codable, Equatable {
    case shape, animation
}

public struct VibeShape: Codable, Identifiable, Equatable {
    public let id: VibeID
    public let containerId: VibeID
    public let width: CGFloat
    public let height: CGFloat
    public let position: CGPoint
    public let color: [CGFloat]
    public let shape: String
    public let objectType: VibeObjectType
    public let zIndex: Int
    public let animation: VibeAnimationSchema
}

public struct VibeSchema: Codable, Equatable {
    public let id: VibeID
    public let objects: [VibeShape]
}

public enum VibeAnimationInvokeType: String, Codable {
    case trigger, auto
}

public struct VibeAnimationSchema: Codable, Identifiable, Equatable {
    public let id: VibeID
    public let initialValues: VibeAnimationValues
    public let invokeType: VibeAnimationInvokeType
    public let keyframes: [VibeAnimationKeyframe]
}

func decodeVibeSchema(json: Data) -> VibeSchema? {
    do {
        let schema = try JSONDecoder().decode(VibeSchema.self, from: json)
        return schema
    } catch {
        print("Failed to decode JSON: \(error.localizedDescription)")
        return nil
    }
}


