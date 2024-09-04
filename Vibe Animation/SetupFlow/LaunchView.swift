//
//  LaunchView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/28/24.
//

import SwiftUI

typealias Tag = Int
let reactTag = 0
let swiftUITag = 1

struct ProjectSelectionView: View {
    @Environment(\.appColors) var appColors: Colors
    
    private let buttonVPadding = 8.0
    
    @State private var showNext: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            ProjectsContainerSplitView {
                VStack(spacing: .zero) {
                    Spacer()
                    LaunchLogo(accentColor: appColors.accent)
                    LaunchLogoTitle()
                    Spacer()
                    
                    ProjectButton(title: "New Project") {
                        showNext = true
                    }
                    .padding(.vertical, buttonVPadding)
                    
                    ProjectButton(title: "Open Project") {
                        
                    }
                    .padding(.vertical, buttonVPadding)
                    
                    Spacer()
                }
                .frame(width: proxy.size.width / 2)
            } contentRight: {
                ProjectsListView()
            }
            .navigationDestination(isPresented: $showNext) {
                SetupFlowChooseFramework()
            }
            .navigationBarBackButtonHidden()
        }
    }
}

struct LaunchView: View {
    var body: some View {
        ProjectSelectionView()
    }
}

#Preview {
    LaunchView()
}
