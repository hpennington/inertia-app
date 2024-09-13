//
//  SetupFlowStartScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/28/24.
//

import Combine
import SwiftUI

typealias Tag = SetupFlowFramework
let reactTag = SetupFlowFramework.react
let swiftUITag = SetupFlowFramework.swiftUI

struct SetupFlowStartScreen: View {
    @Environment(\.appColors) var appColors: Colors
    
    let action: (SetupFlowEvent) -> Void
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
                        action(.newProject)
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
            .navigationBarBackButtonHidden()
        }
    }
}

enum SetupFlowFramework {
    case react, swiftUI
}

final class SetupFlowManager: ObservableObject {
    @Published var framework: SetupFlowFramework = .react
    @Published var projectTitle: String = ""
    @Published var projectDescription: String = ""
    @Published var xcodeProjectURL: String = ""
    @Published var entryStructTitle: String = ""
    @Published var reactProjectURL: String = ""
}

final class SetupFlowVM: ObservableObject {
    @Published private(set) var stateMachine = SetupFlowStateMachine()
    @Published var navigationPath = NavigationPath()
    @Published var setupFlowManager = SetupFlowManager()
    
    private var anyCancellable: Set<AnyCancellable> = Set()
    private var event: SetupFlowEvent? = nil
    
    init() {
        self.stateMachine.$currentState.sink { newState in
            if let event = self.event {
                switch event {
                case .cancelSetup:
                    self.navigationPath.removeLast(self.navigationPath.count)
                case .back:
                    self.navigationPath.removeLast()
                default:
                    self.navigationPath.append(newState)
                }
            }
        }
        .store(in: &anyCancellable)
    }
    
    func handleEvent(_ event: SetupFlowEvent) {
        self.event = event
        stateMachine.handleEvent(event)
    }
}
