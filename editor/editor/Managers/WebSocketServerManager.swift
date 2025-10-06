//
//  WebSocketServerManager.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import Foundation
import Observation
import Inertia

@Observable
@MainActor
final class WebSocketServerManager {
    var servers: [SetupFlowFramework: WebSocketServer] = [:]

    func startServer(
        for framework: SetupFlowFramework,
        port: Int,
        onMessage: @escaping (WebSocketClient.MessageTranslation) -> Void
    ) {
        guard servers[framework] == nil else { return }

        if let server = try? WebSocketServer(port: UInt16(port), translation: onMessage) {
            server.start()
            servers[framework] = server
        }
    }

    func sendSchema(_ schemaWrappers: [InertiaSchemaWrapper], to framework: SetupFlowFramework) -> Result<Int, InertiaSwiftWebsocketError> {
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
}
