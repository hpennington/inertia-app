//
//  TimelineColumn.swift
//  
//
//  Created by Hayden Pennington on 9/7/25.
//

import SwiftUI

struct TimelineColumn<Header: View, Content: View, Footer: View>: View {
    @Binding var playheadProgress: Int
    let playheadLabel: String
    let tickCount: Int
    let header: () -> Header
    let content: () -> Content
    let footer: () -> Footer
    let playheadReleased: () -> Void
    
    let spacing: CGFloat = 50
    
    @State private var width: CGFloat = .zero
    @State private var playheadOffset: CGFloat = .zero
    
    var tickSpacing: CGFloat {
        width / CGFloat(tickCount)
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let offset = value.startLocation.x + value.translation.width
                
                if offset <= .zero {
                    playheadOffset = .zero
                    playheadProgress = 0
                } else if offset >= width - spacing {
                    playheadOffset = width - spacing
                    playheadProgress = tickCount
                } else {
                    let (snap, tick) = snapToNearestTick(value: offset)
                    playheadOffset = snap
                    playheadProgress = tick
                }
            }
            .onEnded { value in
                let offset = value.startLocation.x + value.translation.width
                
                if offset <= .zero {
                    playheadOffset = .zero
                    playheadProgress = 0
                } else if offset >= width - spacing {
                    playheadOffset = width - spacing
                    playheadProgress = tickCount
                } else {
                    let (snap, tick) = snapToNearestTick(value: offset)
                    playheadOffset = snap
                    playheadProgress = tick
                }
                
                playheadReleased()
            }
    }
    
    func snapToNearestTick(value: CGFloat) -> (CGFloat, Int) {
        let spacing = (width - spacing) / CGFloat(tickCount)
        let tick = Int(value / spacing)
        return (spacing * CGFloat(tick), tick)
    }
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                header()
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    self.width = proxy.size.width
                                }
                                .onChange(of: proxy.size.width) { _, newValue in
                                    self.width = newValue
                                }
                        }
                    )
                content()
                footer()
            }
            .padding(.top, 28)
            
            VStack {
                Playhead(label: playheadLabel)
                    .frame(maxHeight: .infinity)
                    .offset(x: playheadOffset, y: 0)
                    .gesture(dragGesture)
                Spacer()
            }
        }
    }
}
