//
//  TimelineRuler.swift
//  Inertia Pro
//
//  Created by Hayden Pennington on 12/27/24.
//

import SwiftUI

struct TimelineRuler: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Canvas { (context, size) in
            let nMajorTicks = 16
            let nMinorTicks = 10
            
            let color = colorScheme == .dark ? Color.gray : Color.black
            
            for majorTick in 0..<nMajorTicks {
                var path = Path()
                
                var endOffset: Int = 0
                
                if majorTick == .zero {
                    endOffset = 1
                } else if majorTick == nMajorTicks - 1 {
                    endOffset = -1
                }
                
                let xMajor = majorTick * Int(size.width) / (nMajorTicks - 1) + endOffset
                let y0 = Int.zero
                let y1 = 12
                path.move(to: CGPoint(x: xMajor, y: y0))
                path.addLine(to: CGPoint(x: xMajor, y: y1))
                context.stroke(path, with: .color(color))
                
                for minorTick in 1..<nMinorTicks {
                    var path = Path()
                
                    let xMinor = xMajor + minorTick * Int(size.width) / (nMinorTicks * (nMajorTicks - 1))
                    let y0 = 4
                    let y1 = 12
                    path.move(to: CGPoint(x: xMinor, y: y0))
                    path.addLine(to: CGPoint(x: xMinor, y: y1))
                    context.stroke(path, with: .color(color))
                }
            }
        }
    }
}

#Preview {
    TimelineRuler()
}
