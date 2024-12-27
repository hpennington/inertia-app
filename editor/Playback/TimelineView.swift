//
//  TimelineView.swift
//  Inertia Pro
//
//  Created by Hayden Pennington on 12/26/24.
//

import SwiftUI

struct TimelineContainer: View {
    @State private var isExpanded: Set<String> = []
    
    var body: some View {
        ScrollView {
            HStack {
                TimelineHierarchy(ids: ["Shape X", "Shape Y", "Shape Z"], isExpanded: $isExpanded)
                
                Spacer()
                
                Timeline {
                    ForEach(["Shape X", "Shape Y", "Shape Z"], id: \.hashValue) { id in
                        TimelineBarBackground()
                            .frame(height: 42)
                        
                        if isExpanded.contains(id) {
                            TimelineBarBackground()
                                .frame(height: 32)
                        }
                    }
                    
                }
            }
        }
    }
}

struct Timeline: View {
    @ViewBuilder var rows: () -> any View
    
    init(@ViewBuilder rows: @escaping () -> any View) {
        self.rows = rows
    }
    
    var body: some View {
        VStack {
            AnyView(rows())
            Spacer(minLength: .zero)
        }
        .padding()
    }
}

struct TimelineBarBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(ColorPalette.gray1.opacity(colorScheme == .dark ? 0.25 : 0.05))
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    Timeline {
        TimelineBarBackground()
            .frame(height: 32)
    }
}
