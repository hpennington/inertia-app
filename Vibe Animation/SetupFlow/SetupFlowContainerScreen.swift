//
//  SetupFlowContainerScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/5/24.
//

import SwiftUI

struct SetupFlowContainerScreen: View {
    @StateObject private var vm = SetupFlowVM()
    
    let completion: (_ framework: SetupFlowFramework) -> Void
    
    func actionHandler(event: SetupFlowEvent) {
        vm.handleEvent(event)
    }
    
    func openFileBrowser(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.begin { response in
            switch response {
            case .OK:
                completion(panel.url)
            default:
                completion(nil)
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $vm.navigationPath) {
            SetupFlowStartScreen(action: actionHandler)
                .navigationDestination(for: SetupFlowState.self) { currentState in
                    switch currentState {
                    case .start:
                        SetupFlowStartScreen(action: actionHandler)
                    case .browsingProject:
                        SetupFlowStartScreen(action: actionHandler)
                            .disabled(true)
                            .onAppear {
                                if vm.isFileBrowserAllowedOpen {
                                    openFileBrowser { url in
                                        guard let url else {
                                            vm.isFileBrowserAllowedOpen = false
                                            actionHandler(event: .cancelSetup)
                                            return
                                        }
                                        
                                        actionHandler(event: .filePicked)
                                        print(vm.openProjectFiles(url: url))
                                        actionHandler(event: .asyncJobFinished)
                                    }
                                    
                                    vm.isFileBrowserAllowedOpen = false
                                }
                            }
                            .onDisappear {
                                vm.isFileBrowserAllowedOpen = true
                            }
                    case .chooseFramework:
                        SetupFlowChooseFrameworkScreen(action: actionHandler)
                    case .projectInfoReact:
                        SetupFlowInfoScreenReact(action: actionHandler)
                    case .projectInfoIOS:
                        SetupFlowInfoScreenSwiftUI(action: actionHandler)
                    case .configurationReact:
                        SetupFlowWebConfigurationScreen(action: actionHandler)
                    case .compilationMode:
                        SetupFlowCompilationModeScreen(action: actionHandler)
                    case .xcodeCheck:
                        SetupFlowInstallXcodeScreen(action: actionHandler)
                    case .configurationSwiftUI:
                        SetupFlowSwiftUIConfigurationScreen(action: actionHandler)
                    case .swiftUICopying:
                        SetupFlowCopyingScreen(action: actionHandler)
                    case .swiftUICompile:
                        SetupFlowCompilingScreen(action: actionHandler)
                    case .projectLoad:
                        SetupFlowProjectLoad(action: actionHandler)
                    case .completeReact:
                        Text("Complete")
                            .onAppear {
                                completion(.react)
                            }
                    case .completeSwiftUI:
                        Text("Complete")
                            .onAppear {
                                completion(.swiftUI)
                            }
                    }
            }
        }
        .environment(\.popNavigationStack, {actionHandler(event: .back)})
        .environmentObject(vm.setupFlowManager)
    }
}

#Preview {
    SetupFlowContainerScreen { isReact in
        
    }
}
