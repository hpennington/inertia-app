//
//  ProjectsListView.swift
//  Inertia Animation
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
                        .foregroundStyle(ColorPalette.gray5)
                }
                .buttonStyle(.plain)

                Button {
                    
                } label: {
                    Text("Project Y")
                        .padding(.vertical, 8)
                        .frame(minHeight: minA11yHeight)
                        .foregroundStyle(ColorPalette.gray5)
                }
                .buttonStyle(.plain)
                
                Button {
                    
                } label: {
                    Text("Project Z")
                        .padding(.vertical, 8)
                        .frame(minHeight: minA11yHeight)
                        .foregroundStyle(ColorPalette.gray5)

                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .foregroundStyle(ColorPalette.gray5)
        }
        .background(ColorPalette.gray2)
    }
}

#Preview {
    ProjectsListView()
}
