//
// Vibe SwiftUI animation library
// Created by Hayden Pennington
//
// Copyright (c) 2024 Vector Studio. All rights reserved.
//

import SwiftUI

public struct VibeContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    public init(
        @ViewBuilder let content: @escaping () -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content()
    }
}

public struct Vibeable<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    public init(
        @ViewBuilder let content: @escaping () -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content()
    }
}
