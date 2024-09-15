//
//  OpenFlowContainerScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/14/24.
//

import Combine
import SwiftUI

final class OpenFlowVM: ObservableObject {
    @Published private(set) var stateMachine = OpenFlowStateMachine()
    @Published var navigationPath = NavigationPath()
    @Published var setupFlowManager = SetupFlowManager()
    
    private var anyCancellable: Set<AnyCancellable> = Set()
    private var event: OpenFlowEvent? = nil
    
    init() {
        self.stateMachine.$currentState.sink { newState in
            if let event = self.event {
                switch event {
                case .cancel:
                    self.navigationPath.removeLast(self.navigationPath.count)
                default:
                    self.navigationPath.append(newState)
                }
            }
        }
        .store(in: &anyCancellable)
    }
    
    func handleEvent(_ event: OpenFlowEvent) {
        self.event = event
        stateMachine.handleEvent(event)
//        
//        switch event {
//        case .openProject(let url):
//            openProjectFiles(url: url)
//        default:
//            break
//        }
    }
}

struct OpenFlowContainerScreen: View {
    @StateObject private var vm = OpenFlowVM()
    
    let completion: (_ framework: SetupFlowFramework) -> Void
    
    func actionHandler(event: OpenFlowEvent) {
        vm.handleEvent(event)
    }
    
    var body: some View {
        NavigationStack(path: $vm.navigationPath) {
//            SetupFlowStartScreen(action: actionHandler)
//                .navigationDestination(for: SetupFlowState.self) { currentState in
//                    switch currentState {
//                    case .chooseFramework:
//                        SetupFlowChooseFrameworkScreen(action: actionHandler)
//                    case .projectInfoReact:
//                        SetupFlowInfoScreenReact(action: actionHandler)
//                    case .projectInfoIOS:
//                        SetupFlowInfoScreenSwiftUI(action: actionHandler)
//                    case .configurationReact:
//                        SetupFlowWebConfigurationScreen(action: actionHandler)
//                    case .compilationMode:
//                        SetupFlowCompilationModeScreen(action: actionHandler)
//                    case .xcodeCheck:
//                        SetupFlowInstallXcodeScreen(action: actionHandler)
//                    case .configurationSwiftUI:
//                        SetupFlowSwiftUIConfigurationScreen(action: actionHandler)
//                    case .swiftUICopying:
//                        SetupFlowCopyingScreen(action: actionHandler)
//                    case .swiftUICompile:
//                        SetupFlowCompilingScreen(action: actionHandler)
//                    case .projectLoad:
//                        SetupFlowProjectLoad(action: actionHandler)
//                    case .completeReact:
//                        Text("Complete")
//                            .onAppear {
//                                completion(.react)
//                            }
//                    case .completeSwiftUI:
//                        Text("Complete")
//                            .onAppear {
//                                completion(.swiftUI)
//                            }
//                    }
//            }
        }
//        .environment(\.popNavigationStack, {actionHandler(event: .back)})
//        .environmentObject(vm.setupFlowManager)
    }
}
