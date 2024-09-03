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
    
    var body: some View {
        GeometryReader { proxy in
            ProjectsContainerSplitView {
                VStack(spacing: .zero) {
                    Spacer()
                    LaunchLogo(accentColor: appColors.accent)
                    LaunchLogoTitle()
                    Spacer()
                    ProjectButton(title: "New Project") {
                        
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
        }
    }
}

struct SetupFlowBase<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack {
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.gray2)
    }
}

struct SetupFlowSetupWeb: View {
    @Binding var title: String
    @Binding var serverURL: String
    
    var body: some View {
        SetupFlowBase {
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

struct SetupFlowProjectType: View {
    @Binding var tag: Tag
    
    var body: some View {
        SetupFlowBase {
            Text("Project Type")
            
            RadioGroup(selectedTag: $tag) {
                RadioButton(tag: 0) {
                    RadioButtonContent(title: "Web (React)")
                }
                RadioButton(tag: 1) {
                    RadioButtonContent(title: "iOS (SwiftUI)")
                }
            }
            
            Button {
                
            } label: {
                Text("Continue")
            }
        }
    }
}

struct LaunchView: View {
    @State private var tag: Tag = 0

    var body: some View {
        SetupFlowProjectType(tag: $tag)
    }
}

#Preview {
    SetupFlowBase {
        Text("Project Type")
        
        Button {
            
        } label: {
            Text("iOS (SwiftUI)")
        }
        
        Button {
            
        } label: {
            Text("Web (React)")
        }
        
        Button {
            
        } label: {
            Text("Continue")
        }
    }
}
