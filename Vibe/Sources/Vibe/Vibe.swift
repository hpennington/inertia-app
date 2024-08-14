//
// Vibe SwiftUI animation library
// Created by Hayden Pennington
//
// Copyright (c) 2024 Vector Studio. All rights reserved.
//

import SwiftUI

private struct VibeDataModelKey: EnvironmentKey {
    static let defaultValue = VibeDataModel(containerId: "")
}

extension EnvironmentValues {
    var vibeDataModel: VibeDataModel {
        get { self[VibeDataModelKey.self] }
        set { self[VibeDataModelKey.self] = newValue }
    }
}

public final class VibeDataModel {
    public let containerId: String
    
    public init(containerId: String) {
        self.containerId = containerId
    }
}

public struct VibeContainer<Content: View>: View {
    let id: String
    
    @State private var vibeDataModel: VibeDataModel
    @ViewBuilder let content: () -> Content
    
    public init(
        id: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.id = id
        self.content = content
        self._vibeDataModel = State(wrappedValue: VibeDataModel(containerId: id))
    }
    
    public var body: some View {
        content()
            .environment(\.vibeDataModel, self.vibeDataModel)
    }
}

public struct Vibeable<Content: View>: View {
    @Environment(\.vibeDataModel) var vibeDataModel: VibeDataModel
    
    @ViewBuilder let content: () -> Content
    
    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content()
            .onAppear {
                print(vibeDataModel.containerId)
            }
    }
}
