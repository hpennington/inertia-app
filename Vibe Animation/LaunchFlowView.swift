//
//  LaunchFlowView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/28/24.
//

import SwiftUI

struct ProjectSelectionView: View {
    @Environment(\.appColors) var appColors: Colors
    
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: .zero) {
                VStack {
                    Spacer()
                    Circle()
                        .fill(appColors.accent)
                        .frame(width: 46, height: 46)
                        .padding()
                    Text("Vibe Animator")
                        .font(.title)
                        .foregroundStyle(ColorPalette.white)
                    Spacer()
                    Button {
                        
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ColorPalette.gray2.opacity(0.5))
                                
                            Text("New Project")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .foregroundStyle(ColorPalette.gray3)
                        }
                        .frame(width: 250, height: 44)
                        .padding()
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .frame(width: proxy.size.width / 2)
                .frame(maxHeight: .infinity)
                .background(ColorPalette.gray1)
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Projects")
                            .font(.title)
                            .bold()
                        
                        Button {
                            
                        } label: {
                            Text("Project X")
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)

                        Button {
                            
                        } label: {
                            Text("Project Y")
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            
                        } label: {
                            Text("Project Z")
                                .padding(.vertical, 8)

                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .foregroundStyle(ColorPalette.white)
                }
                .frame(width: proxy.size.width / 2)
                .background(ColorPalette.gray2)
            }
        }
    }
}

struct LaunchFlowView: View {
    var body: some View {
        ProjectSelectionView()
        
    }
}

#Preview {
    LaunchFlowView()
}
