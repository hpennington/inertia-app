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
        // Don't start if server already exists for this framework
        guard servers[framework] == nil else {
            print("⚠️ Server for \(framework) already running on port \(port)")
            return
        }

        do {
            let server = try WebSocketServer(port: UInt16(port), translation: onMessage)
            server.start()
            servers[framework] = server
            print("✅ Started server for \(framework) on port \(port)")
        } catch {
            print("❌ Failed to start server for \(framework) on port \(port): \(error)")
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
