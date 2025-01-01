//
//  TimelineView.swift
//  Inertia Pro
//
//  Created by Hayden Pennington on 12/26/24.
//

import SwiftUI

struct TimelineRow: View {
    let isExpanded: Bool
    let keypoints: [Int]
    
    let insertKeypoint: (_ millis: Int) -> Void
    
    @State private var proxyWidth: CGFloat? = nil
    
    var body: some View {
        TimelineBarBackground { locationX in
            if let proxyWidth {
                insertKeypoint(Int((locationX * 1000 * 3) / proxyWidth))
            }
        }
        .frame(height: 42)
        .overlay {
            GeometryReader { proxy in
                ZStack() {
                    ForEach(0..<keypoints.count, id: \.self) { index in
                        let value = keypoints[index]
                        let x = CGFloat(Int((CGFloat(value) / 1000 / 3) * proxy.size.width))
                        TimelineKeypointIndicator()
                            .position(x: x, y: 21)
                    }
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    proxyWidth = proxy.size.width
                }
                .onChange(of: proxy.size.width) { oldValue, newValue in
                    proxyWidth = newValue
                }
            }
            .frame(maxWidth: .infinity)
        }
        
        if isExpanded {
            TimelineBarTransformBackground()
                .frame(height: 32)
        }
    }
}

struct TimelineContainer: View {
    @Environment(\.appColors) var appColors
    @State private var isExpanded: Set<String> = []
    
    @Binding var isPlaying: Bool
    @Binding var rowData: [String: [Int]]
    
    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                HStack(alignment: .bottom) {
                    Button {
                        Task {
                            isPlaying.toggle()
                        }
                    } label: {
                        Image(systemName: "play.fill")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(appColors.accent)
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                    .padding([.leading, .trailing, .top])
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: .zero)
                }
                .frame(maxHeight: .infinity)
                HStack(alignment: .bottom) {
                    TimelineHierarchy(ids: rowData.map {$0.0}, isExpanded: $isExpanded)
//                        .padding(.top, 32)
                        .frame(minWidth: 256 + 16)
                
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
                            .padding(.bottom, 8)
                        
                        VStack {
                            ForEach(Array(rowData.keys.map {String($0)}), id: \.self) { key in
                                TimelineRow(isExpanded: isExpanded.contains(key), keypoints: rowData[key] ?? []) { millis in
                                    rowData[key]?.append(millis)
                                }
                            }
                        }
                        
                    }
                    
                    Spacer(minLength: .zero)
                }
                .frame(maxHeight: .infinity)
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
        VStack(alignment: .center, spacing: .zero) {
            AnyView(rows())
                .padding(.horizontal)
            Spacer(minLength: .zero)
        }
    }
}

struct TimelineBarTransformBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(ColorPalette.gray1.opacity(colorScheme == .dark ? 0.25 : 0.05))
            .frame(maxWidth: .infinity)
    }
}

struct TimelineBarBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    let insertKeypoint: (_ x: CGFloat) -> Void
    
    @State private var hoverLocationX: CGFloat? = nil
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(ColorPalette.gray1.opacity(colorScheme == .dark ? 0.25 : 0.05))
            .frame(maxWidth: .infinity)
            .overlay {
                if let hoverLocationX {
                    Button {
                        insertKeypoint(hoverLocationX)
                    } label: {
                        Image(systemName: "plus.app")
                    }
                    .position(x: hoverLocationX)
                }
            }
            .onContinuousHover(coordinateSpace: .local, perform: { phase in
                switch phase {
                case .active(let location):
                    hoverLocationX = location.x
                case .ended:
                    hoverLocationX = nil
                }
            })
    }
}

#Preview {
    Timeline {
        TimelineBarTransformBackground()
            .frame(height: 32)
    }
}
