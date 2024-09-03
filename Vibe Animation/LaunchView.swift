//
//  LaunchView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/28/24.
//

import SwiftUI

typealias Tag = Int

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

struct SetupFlowBase<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: .zero) {

            HStack(spacing: .zero) {
                NavigationBackButton {
                    dismiss()
                }
                .padding(.vertical, 8)
                
                Spacer()
                
                SetupTitleView(title: title)
                
                Spacer()
                NavigationBackButton {
                    
                }
                .padding(.vertical, 8)
                .hidden()
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: .zero) {
                content()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.gray2)
    }
}

struct SetupFlowSetupWeb: View {
    @Binding var title: String
    @Binding var serverURL: String
    
    var body: some View {
        SetupFlowBase(title: "Setup") {
            Text("Setup")
            
            TextField("Title", text: $title)
            TextField("Server URL", text: $serverURL)
            
            Button {
                
            } label: {
                Text("Continue")
            }
        }
    }
}

struct SetupFlowChooseFramework: View {
    @State private var tag: Tag = 0
    
    var body: some View {
        SetupFlowBase(title: "Choose a Framework") {
            VStack(spacing: 16) {
                Spacer(minLength: 8)
                    .frame(height: 8)

                RadioGroup(selectedTag: $tag) {
                    RadioButton(tag: 0) {
                        RadioButtonContent(title: "Web (React)")
                    }
                    RadioButton(tag: 1) {
                        RadioButtonContent(title: "iOS (SwiftUI)")
                    }
                }
                
                Spacer()
                
                SetupActionButton(title: "Continue") {
                    
                }
                
                Spacer()
            }
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
