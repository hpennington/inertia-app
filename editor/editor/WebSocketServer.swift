//
//  WebSocketServer.swift
//  Inertia App
//
//  Created by Hayden Pennington on 9/8/25.
//

import Foundation
import Network
import Inertia

enum InertiaSwiftWebsocketError: Error {
    case didFailToEval(Error)
    case serverNil
}

@Observable
final class WebSocketServer {
    let listener: NWListener
    var clients: [UUID: NWConnection] = [:]
    var treePackets: [TreePacket] = []
    var treePacketsLUT: [String: Int] = [:]
    let translation: (WebSocketClient.MessageTranslation) -> Void

    init(port: UInt16, translation: @escaping (_ message: WebSocketClient.MessageTranslation) -> Void) throws {
        self.translation = translation
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
    
    func reset() {
        for client in clients.values {
            client.cancel()
        }
        
        clients.removeAll()
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
                self.reset()
            case .cancelled:
                print("⚠️ Connection cancelled: \(clientId)")
                self.reset()
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
//                self?.clients.removeValue(forKey: clientId)
                self?.reset()
//                self?.errorCallback()
                return
            }

            guard let context = context else { return }
            if let wsMetadata = context.protocolMetadata(definition: NWProtocolWebSocket.definition) as? NWProtocolWebSocket.Metadata {
                switch wsMetadata.opcode {
                case .close:
                    print("🔌 Client closed connection: \(clientId)")
//                    self?.clients.removeValue(forKey: clientId)
//                    self?.errorCallback()
                    self?.reset()
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
        case .translationEnded:
            let msg = try! JSONDecoder().decode(WebSocketClient.MessageTranslation.self, from: messageWrapper.payload)
            updateKeyframeTranslation(with: msg)
        }
    }
    
    private func updateKeyframeTranslation(with msg: WebSocketClient.MessageTranslation) {
        translation(msg)
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

    func sendSelectedIds(_ ids: Set<ActionableIdPair>, tree: Tree, to clientId: UUID) {
        send(type: .actionables, payload: WebSocketClient.MessageActionables(tree: tree, actionableIds: ids), to: clientId)
    }

    func sendSchema(_ schemaWrappers: [InertiaSchemaWrapper], to clientId: UUID) {
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
