//
//  TimelineView.swift
//  Inertia Pro
//
//  Created by Hayden Pennington on 12/26/24.
//

import SwiftUI

struct TimelineContainer: View {
    @Environment(\.appColors) var appColors
    @State private var isExpanded: Set<String> = []
    
    @Binding var isPlaying: Bool
    
    var body: some View {
        ScrollView {
            Grid {
                GridRow {
                    Button {
                        Task {
                            isPlaying.toggle()
                        }
                    } label: {
                        Image(systemName: "play")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(appColors.accent)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                GridRow {
                    TimelineHierarchy(ids: ["Shape X", "Shape Y", "Shape Z"], isExpanded: $isExpanded)
    //                        .padding(.top, 36)
                
                    Timeline {
                        HStack {
                            Text("0.0")
                            Spacer()
                            Text("0.2")
                            Spacer()
                            Text("0.4")
                            Spacer()
                            Text("0.6")
                            Spacer()
                            Text("0.8")
                            Spacer()
                            Text("1.0")
                            Spacer()
                            Text("1.2")
                            Spacer()
                            Text("1.4")
                            Spacer()
                            Text("1.6")
                            Spacer()
                            Text("1.8")
                            Spacer()
                            Text("2.0")
                            Spacer()
                            Text("2.2")
                            Spacer()
                            Text("2.4")
                            Spacer()
                            Text("2.6")
                            Spacer()
                            Text("2.8")
                            Spacer()
                            Text("3.0")
                        }
                        .frame(maxWidth: .infinity)
                        
                        TimelineRuler()
                        
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
}

struct Timeline: View {
    @ViewBuilder var rows: () -> any View
    
    init(@ViewBuilder rows: @escaping () -> any View) {
        self.rows = rows
    }
    
    var body: some View {
        VStack(alignment: .center) {
            AnyView(rows())
                .padding(.horizontal)
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
