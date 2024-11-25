//
// Vibe SwiftUI animation library
// Created by Hayden Pennington
//
// Copyright (c) 2024 Vector Studio. All rights reserved.
//

import SwiftUI

public typealias VibeID = String

public class Node: Identifiable, Codable, CustomStringConvertible {
    public let id: String
    public var children: [Node]? = []
    
    init(id: String) {
        self.id = id
    }
    
    func addChild(_ child: Node) {
        children?.append(child)
    }
    
    public var description: String {
        "{id: \(id), children: \(children)}"
    }
}

public struct Tree: Codable, CustomStringConvertible {
    private var nodeMap: [String: Node] = [:]
    public var rootNode: Node?

    mutating func addRelationship(id: String, parentId: String?, root: Bool) {
        // Get or create the current node
        let currentNode = nodeMap[id] ?? {
            let newNode = Node(id: id)
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

            if root {
                // If explicitly marked as root, set it as the root node
                // Establish parent-child relationship
                parentNode.addChild(currentNode)
                rootNode = parentNode
            } else {
                parentNode.addChild(currentNode)
                rootNode = currentNode
            }
        }
    }
    
    public var description: String {
        "root: \(rootNode)"
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

public final class VibeDataModel {
    public let containerId: VibeID
    public let vibeSchema: VibeSchema
    public var tree: Tree
    public var actionableIds: Set<String>
    
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
                self._vibeDataModel = State(wrappedValue: VibeDataModel(containerId: id, vibeSchema: schema, tree: Tree(), actionableIds: Set()))
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
                    if let receivedString = try? JSONDecoder().decode(Tree.self, from: data) {
                        print("Received message (data): \(receivedString)")
                    } else {
                        print("Received binary data that could not be converted to string.")
                    }
                case .string(let text):
                    print("Received message (text): \(text)")
                @unknown default:
                    print("Received an unknown message type.")
                }
                
                self.receiveMessage(task: task)
            }
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

struct VibeHello<Content: View>: View {
    let hierarchyID: String
    let content: Content
    
    @Environment(\.vibeDataModel) var vibeDataModel
    @Environment(\.inertiaParentID) var inertiaParentID
    @Environment(\.isInertiaContainer) var isInertiaContainer
    
    @State private var showSelectedBorder = false
    let manager = WebSocketSharedManager.shared
    
    var body: some View {
        content
            .environment(\.inertiaParentID, hierarchyID)
            .environment(\.isInertiaContainer, false)
            .onTapGesture {
                print("tapped \(content)")
                showSelectedBorder.toggle()
                
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
                print("onAppear: \(hierarchyID)")
                vibeDataModel?.tree.addRelationship(id: hierarchyID, parentId: inertiaParentID, root: isInertiaContainer)
                print(vibeDataModel?.tree)
                    
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


