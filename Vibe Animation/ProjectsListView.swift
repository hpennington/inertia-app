//
//  ProjectsListView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 8/26/24.
//

import SwiftUI

struct ProjectsListView: View {
    private let minA11yHeight = 32.0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Recently Opened")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.secondary)
                
                Button {
                    
                } label: {
                    Text("Project X")
                        .padding(.vertical, 8)
                        .frame(minHeight: minA11yHeight)
                        .foregroundStyle(ColorPalette.gray3)
                }
                .buttonStyle(.plain)

                Button {
                    
                } label: {
                    Text("Project Y")
                        .padding(.vertical, 8)
                        .frame(minHeight: minA11yHeight)
                        .foregroundStyle(ColorPalette.gray3)
                }
                .buttonStyle(.plain)
                
                Button {
                    
                } label: {
                    Text("Project Z")
                        .padding(.vertical, 8)
                        .frame(minHeight: minA11yHeight)
                        .foregroundStyle(ColorPalette.gray3)

                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .foregroundStyle(ColorPalette.white)
        }
        .background(ColorPalette.gray2)
    }
}

#Preview {
    ProjectsListView()
}
