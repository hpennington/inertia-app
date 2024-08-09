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

struct SetupFlowBase<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack {
            content()
        }
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
    @Binding var web: Bool?
    
    var body: some View {
        SetupFlowBase {
            Text("Project Type")
            
            Button {
                web = false
            } label: {
                Text("iOS (SwiftUI)")
            }
            
            Button {
                web = true
            } label: {
                Text("Web (React)")
            }
            
            Button {
                
            } label: {
                Text("Continue")
            }
            .disabled(web == nil)
        }
    }
}

struct LaunchFlowView: View {
    var body: some View {
        ProjectSelectionView()
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
