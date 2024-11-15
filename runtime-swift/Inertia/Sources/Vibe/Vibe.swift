//
// Vibe SwiftUI animation library
// Created by Hayden Pennington
//
// Copyright (c) 2024 Vector Studio. All rights reserved.
//

import SwiftUI

public typealias VibeID = String
//
//private struct VibeDataModelKey: EnvironmentKey {
//    static let defaultValue = VibeDataModel(containerId: "", vibeSchema: VibeSchema(id: "", objects: []))
//}
//
//extension EnvironmentValues {
//    var vibeDataModel: VibeDataModel {
//        get { self[VibeDataModelKey.self] }
//        set { self[VibeDataModelKey.self] = newValue }
//    }
//}
//
//public final class VibeDataModel {
//    public let containerId: VibeID
//    public let vibeSchema: VibeSchema
//    
//    public init(containerId: VibeID, vibeSchema: VibeSchema) {
//        self.containerId = containerId
//        self.vibeSchema = vibeSchema
//    }
//}
//
//public struct VibeContainer<Content: View>: View {
//    let bundle: Bundle
//    let id: VibeID
//    
//    @State private var vibeDataModel: VibeDataModel
//    @ViewBuilder let content: () -> Content
//    
//    public init(
//        bundle: Bundle = Bundle.main,
//        id: VibeID,
//        @ViewBuilder content: @escaping () -> Content
//    ) {
//        self.bundle = bundle
//        self.id = id
//        self.content = content
//        
//        // TODO: - Solve error handling when file is missing or schema is wrong
//        if let url = bundle.url(forResource: id, withExtension: "json") {
//            let schemaText = try! String(contentsOf: url, encoding: .utf8)
//            if let data = schemaText.data(using: .utf8),
//               let schema = decodeVibeSchema(json: data) {
//                self._vibeDataModel = State(wrappedValue: VibeDataModel(containerId: id, vibeSchema: schema))
//            } else {
//                fatalError()
//            }
////            else {
////                print("Failed to parse the schema")
////                fatalError()
//////                self._vibeDataModel = State(wrappedValue: VibeDataModel(containerId: id))
////            }
//        } else {
//            print("Failed to parse the vibe file")
//            fatalError()
////            self._vibeDataModel = State(wrappedValue: VibeDataModel(containerId: id))
//        }
//    }
//    
//    public var body: some View {
//        content()
//            .environment(\.vibeDataModel, self.vibeDataModel)
//    }
//}
//
//public struct Vibeable<Content: View>: View {
//    @ViewBuilder let content: () -> Content
//    
//    public init(
//        @ViewBuilder content: @escaping () -> Content
//    ) {
//        self.content = content
//    }
//    
//    public var body: some View {
//        content()
//    }
//}

import Foundation

func sendData(uri: URL, data: [String: Any]) {
    let task = URLSession.shared.webSocketTask(with: uri)
    task.resume()

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Error: Could not encode JSON to String")
            return
        }
        
        let message = URLSessionWebSocketTask.Message.string(jsonString)
        task.send(message) { error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                print("Message sent: \(jsonString)")
            }
            
            // Begin receiving responses
            receiveMessage(task: task)
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
                if let receivedString = String(data: data, encoding: .utf8) {
                    print("Received message (data): \(receivedString)")
                } else {
                    print("Received binary data that could not be converted to string.")
                }
            case .string(let text):
                print("Received message (text): \(text)")
            @unknown default:
                print("Received an unknown message type.")
            }
            
            receiveMessage(task: task)
        }
    }
}

var connected = false


import Foundation
//
//func getIPAddress() -> [String] {
//    var addresses = [String]()
//
//    // Get list of all interfaces on the local machine:
//    var ifaddr : UnsafeMutablePointer<ifaddrs>?
//    guard getifaddrs(&ifaddr) == 0 else { return [] }
//    guard let firstAddr = ifaddr else { return [] }
//
//    // For each interface ...
//    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
//        let flags = Int32(ptr.pointee.ifa_flags)
//        let addr = ptr.pointee.ifa_addr.pointee
//
//        // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
//        if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
//            if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
//
//                // Convert interface address to a human readable string:
//                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
//                if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
//                                nil, socklen_t(0), NI_NUMERICHOST) == 0) {
//                    let address = String(cString: hostname)
//                    addresses.append(address)
//                }
//            }
//        }
//    }
//
//    freeifaddrs(ifaddr)
//    return addresses
//}

//func getHostIPAddressFromResolvConf() -> String? {
//    guard let resolvContents = try? String(contentsOfFile: "/etc/resolv.conf") else { return nil }
//
//    let lines = resolvContents.components(separatedBy: "\n")
//    for line in lines.reversed() {
//        if line.starts(with: "nameserver") {
//            let components = line.components(separatedBy: " ")
//            if components.count > 1 {
//                return components[1] // IP address
//            }
//        }
//    }
//    return nil
//}
//

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

struct VibeHello<Content: View>: View {
    let content: Content
    
    @State private var showSelectedBorder = false
    
    var body: some View {
        content
            .onTapGesture {
                print("tapped \(content)")
                showSelectedBorder.toggle()
            }
            .overlay {
                if showSelectedBorder {
                    Rectangle()
                        .stroke(Color.green)
                }
            }
            .onAppear {
                if !connected {
                    if let ip = getHostIPAddressFromResolvConf() {
                        let uri = URL(string: "ws://\(ip):8060")!
                        let data: [String: Any] = ["msg": "Sample message data text"]
                        
                        print("Starting to send data...")
                        sendData(uri: uri, data: data)
                        connected = true
                    }
                }
            }
    }
}

extension View {
    public func vibeHello() ->  some View {
        VibeHello(content: self)
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


