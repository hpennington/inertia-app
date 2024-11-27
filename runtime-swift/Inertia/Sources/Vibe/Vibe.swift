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
    static let defaultValue: VibeDataModel? = nil
}

private struct InertiaParentIDKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

private struct IsInertiaContainerKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var vibeDataModel: VibeDataModel? {
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
    
    var isInertiaContainer: Bool {
        get {
            self[IsInertiaContainerKey.self]
        }
        set {
            self[IsInertiaContainerKey.self] = newValue
        }
    }
}

@Observable
public final class VibeDataModel {
    public let containerId: VibeID
    public let vibeSchema: VibeSchema
    public var tree: Tree
    public var actionableIds: Set<String>
    public var isActionable: Bool = true
    
    public init(containerId: VibeID, vibeSchema: VibeSchema, tree: Tree, actionableIds: Set<String>) {
        self.containerId = containerId
        self.vibeSchema = vibeSchema
        self.tree = tree
        self.actionableIds = actionableIds
    }
}

public struct VibeContainer<Content: View>: View {
    let bundle: Bundle
    let id: VibeID
    let hierarchyID: String
    @State private var vibeDataModel: VibeDataModel
    @ViewBuilder let content: () -> Content
    
    public init(
        bundle: Bundle = Bundle.main,
        id: VibeID,
        hierarchyID: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.bundle = bundle
        self.id = id
        self.hierarchyID = hierarchyID
        self.content = content
        
        // TODO: - Solve error handling when file is missing or schema is wrong
        if let url = bundle.url(forResource: id, withExtension: "json") {
            let schemaText = try! String(contentsOf: url, encoding: .utf8)
            if let data = schemaText.data(using: .utf8),
               let schema = decodeVibeSchema(json: data) {
                self._vibeDataModel = State(wrappedValue: VibeDataModel(containerId: id, vibeSchema: schema, tree: Tree(id: id), actionableIds: Set()))
            } else {
                fatalError()
            }
//            else {
//                print("Failed to parse the schema")
//                fatalError()
////                self._vibeDataModel = State(wrappedValue: VibeDataModel(containerId: id))
//            }
        } else {
            print("Failed to parse the vibe file")
            fatalError()
//            self._vibeDataModel = State(wrappedValue: VibeDataModel(containerId: id))
        }
    }
    
    public var body: some View {
        content()
            .environment(\.inertiaParentID, hierarchyID)
            .environment(\.vibeDataModel, self.vibeDataModel)
            .environment(\.isInertiaContainer, true)
    }
}

public class WebSocketSharedManager {
    var task: URLSessionWebSocketTask? = nil
    var isConnected: Bool = false
    public var messageReceived: ((_ selectedIds: Set<String>) -> Void)!
    public var messageReceivedSchema: ((_ schema: [String]) -> Void)!
    static let shared = WebSocketSharedManager()

    init() {

    }
    
    func connect(uri: URL) {
        self.task = URLSession.shared.webSocketTask(with: uri)
        self.task?.resume()
        isConnected = true
    }
    
    public struct MessageItem: Codable {
        public let tree: Tree
        public let actionableIds: Set<String>
    }
    
    public struct MessageItem2: Codable {
        public let selectedIds: Set<String>
        
        public init(selectedIds: Set<String>) {
            self.selectedIds = selectedIds
        }
    }
    
    public struct MessageItem3: Codable {
        public let schema: [String]
        
        public init(schema: [String]) {
            self.schema = schema
        }
    }
    
    func sendData(message: MessageItem) {
        do {
            guard let jsonData = try? JSONEncoder().encode(message) else {
                print("Error: Could not encode JSON to data")
                 return
            }

            let messageData = URLSessionWebSocketTask.Message.data(jsonData)
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
                    
                    if let receivedSelectedIds = try? JSONDecoder().decode(WebSocketSharedManager.MessageItem2.self, from: data) {
                        print("Received message (data): \(receivedSelectedIds)")
                        self.messageReceived(receivedSelectedIds.selectedIds)
                    } else if let receivedVibeSchema = try? JSONDecoder().decode(WebSocketSharedManager.MessageItem3.self, from: data) {
                        print("Received message (data): \(receivedVibeSchema)")
                        self.messageReceivedSchema(receivedVibeSchema.schema)
                    }
                        
//                    } else {
//                        print("Received binary data that could not be converted to string.")
//                    }
                        
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

let manager = WebSocketSharedManager.shared

struct VibeHello<Content: View>: View {
    let hierarchyID: String
    let content: Content
    
    @Environment(\.vibeDataModel) var vibeDataModel
    @Environment(\.inertiaParentID) var inertiaParentID
    @Environment(\.isInertiaContainer) var isInertiaContainer
    
    var showSelectedBorder: Bool {
        guard let vibeDataModel else {
            return false
        }
        
        return vibeDataModel.actionableIds.contains(hierarchyID)
    }

    var body: some View {
        if vibeDataModel?.isActionable ?? false {
            ZStack(alignment: .center) {
                content
            }
            .environment(\.inertiaParentID, hierarchyID)
            .environment(\.isInertiaContainer, false)
            .buttonStyle(.plain)
            .onTapGesture {
                print("tapped \(content)")
                guard let vibeDataModel else {
                    return
                }

                if vibeDataModel.actionableIds.contains(hierarchyID) {
                    vibeDataModel.actionableIds.remove(hierarchyID)
                } else {
                    vibeDataModel.actionableIds.insert(hierarchyID)
                }
                
                if let ip = getHostIPAddressFromResolvConf() {
                    let uri = URL(string: "ws://\(ip):8060")!
    //                    let data: [String: Tree?] = ["tree": vibeDataModel?.tree]
                    
                    print("Starting to send data...")
                    
                    if !manager.isConnected {
                        manager.connect(uri: uri)
                    }
                    
                    let tree = vibeDataModel.tree
                    let actionableIds = vibeDataModel.actionableIds
                    let message = WebSocketSharedManager.MessageItem(tree: tree, actionableIds: actionableIds)
                    manager.sendData(message: message)
                }
            }
            .overlay {
                if showSelectedBorder {
                    Rectangle()
                        .stroke(Color.green)
                }
            }
            .onAppear {
                if let ip = getHostIPAddressFromResolvConf() {
                    let uri = URL(string: "ws://\(ip):8060")!
    //                    let data: [String: Tree?] = ["tree": vibeDataModel?.tree]
                    
                    print("Starting to send data...")
                    
                    if !manager.isConnected {
                        manager.connect(uri: uri)
                    }
                    
                    manager.messageReceived = handleMessage
                    manager.messageReceivedSchema = handleMessageSchema
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
                print("onAppear: \(hierarchyID)")
                NSLog("adding relationship: hierarchyID: \(hierarchyID) inertiaParentID: \(inertiaParentID), isInertiaContainer: \(isInertiaContainer)")
                vibeDataModel?.tree.addRelationship(id: hierarchyID, parentId: inertiaParentID, parentIsContainer: isInertiaContainer)
                if let tree = vibeDataModel?.tree {
                    for node in tree.nodeMap.values {
                        node.tree = tree
                        node.link()
                    }
                }
                
                if let ip = getHostIPAddressFromResolvConf() {
                    let uri = URL(string: "ws://\(ip):8060")!
    //                    let data: [String: Tree?] = ["tree": vibeDataModel?.tree]
                    
                    print("Starting to send data...")
                    
                    if !manager.isConnected {
                        manager.connect(uri: uri)
                    }
                    
                    if let tree = vibeDataModel?.tree, let actionableIds = vibeDataModel?.actionableIds {
                        let message = WebSocketSharedManager.MessageItem(tree: tree, actionableIds: actionableIds)
                        manager.sendData(message: message)
                    }
                }
            }
        } else {
            content
        }
    }
    
    func handleMessage(selectedIds: Set<String>) {
        vibeDataModel?.actionableIds = selectedIds
    }
    
    func handleMessageSchema(schema: [String]) {
        NSLog("\(schema)")
    }
}

extension View {
    public func vibeHello(hierarchyID: String) ->  some View {
        VibeHello(hierarchyID: hierarchyID, content: self)
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


