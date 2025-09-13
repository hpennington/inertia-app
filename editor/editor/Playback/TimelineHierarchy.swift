//
//  TimelineHierarchy.swift
//  Inertia Pro
//
//  Created by Hayden Pennington on 12/26/24.
//

import SwiftUI

struct TimelineHierarchy: View {
    let ids: [String]
    let isExpanded: Binding<Set<String>>
    
    var body: some View {
        VStack {
            ForEach(ids, id: \.hashValue) { id in
                TimelineHierarchyCell(id: id, isExpanded: Binding(get: {
                    isExpanded.wrappedValue.contains(id)
                }, set: { newValue in
                    if newValue {
                        isExpanded.wrappedValue.insert(id)
                    } else {
                        isExpanded.wrappedValue.remove(id)
                    }
                }) )
            }
        }
        .padding(.horizontal, 16)
    }
}

struct TimelineHierarchyCell: View {
    @Environment(\.appColors) var colors
    @Environment(\.colorScheme) var colorScheme
    
    let id: String
    @Binding var isExpanded: Bool
    
    var body: some View {
        Button {
            isExpanded.toggle()
        } label: {
            HStack {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
                    .foregroundColor(ColorPalette.gray4)
                
                Text(String(id))
//                Text(String(id.reversed()).prefix(8))
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black.opacity(0.5))
                    .bold()
                
                Spacer(minLength: .zero)
            }
            .frame(width: 256, height: 42)
            .background(ColorPalette.accentTheme.opacity(0.125))
            
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(ColorPalette.accentTheme.opacity(0.5), lineWidth: 2)
            }
            
        }
        .buttonStyle(.plain)
        
        if isExpanded {
            TimelineHierarchyTransformCell(id: "Translation")
        }
    }
}

struct TimelineHierarchyTransformCell: View {
    @Environment(\.appColors) var colors
    @Environment(\.colorScheme) var colorScheme
    
    let id: String
    
    var body: some View {
        Text(id)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black.opacity(0.5))
            .frame(width: 256, height: 32)
            .background(ColorPalette.gray1.opacity(colorScheme == .dark ? 0.25 : 0.05))
            .cornerRadius(8)
    }
}

#Preview {
    @State var isExpanded: Set<String> = []
    return TimelineHierarchy(ids: ["Shape X", "Shape Y", "Shape Z"], isExpanded: $isExpanded).padding()
}
