//
//  MainLayout.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

struct MainLayout<Leading: View, Content: View, Trailing: View, Bottom: View>: View {
    let spacing: CGFloat = 3
    let cornerRadius: CGFloat = 4
    let leading: () -> Leading
    let content: () -> Content
    let trailing: () -> Trailing
    let bottom: () -> Bottom
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                leading()
                    .cornerRadius(bottomRight: cornerRadius)
                
                content()
                    .cornerRadius(bottomRight: cornerRadius, bottomLeft: cornerRadius)
                
                trailing()
                    .cornerRadius(bottomLeft: cornerRadius)
            }
            
            bottom()
        }
        .ignoresSafeArea(edges: .top)
        
    }
}
