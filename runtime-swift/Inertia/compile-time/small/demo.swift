/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view showing donuts in a box.
*/

// Other comment

import SwiftUI

public struct DonutBoxView<Content: View>: View {
    var isOpen: Bool
    var content: Content
    
    public init(isOpen: Bool, @ViewBuilder content: () -> Content) {
        self.isOpen = isOpen
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            Image("box/Inside", bundle: .module)
                .resizable()
                .scaledToFit()
            
            content
                .frame(width: 12, height: 12)
            
            VStack {
                DonutBoxView2(isOpen: false)
                    .padding(.horizontal)
                    
                Spacer()
                Text("testing")
            }

            
        }
    }
}


public struct DonutBoxView2: View {
    public init(isOpen: Bool) {
        self.isOpen = isOpen
    }
    
    public var body: some View {
        VStack {
            Image("box/Bottom", bundle: .module)
                .resizable()
                .scaledToFit()
            Spacer()
            Text("testing")    
        }
    }
}
