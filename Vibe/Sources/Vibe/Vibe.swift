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
//    @Environment(\.vibeDataModel) var vibeDataModel: VibeDataModel
//    
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
//            .onAppear {
//                print(vibeDataModel.containerId)
//            }
//    }
//}

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
    public let width: CGFloat
    public let height: CGFloat
    public let position: CGPoint
    public let color: [CGFloat]
    public let shape: String
    public let objectType: VibeObjectType
    public let zIndex: Int
    public let animation: VibeAnimationSchema
}

public struct VibeSchema: Codable, Identifiable, Equatable {
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

