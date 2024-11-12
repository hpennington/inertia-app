//
//  SetupFlowContainerScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/5/24.
//

import SwiftUI
import Inertia

struct SetupFlowContainerScreen: View {
    let navigationPath: Binding<NavigationPath>
    let framework: Binding<SetupFlowFramework>
    let setupFlowManager: SetupFlowManager
    let animations: Binding<[VibeSchema]>
    let handleEvent: (SetupFlowEvent) -> Void
    
    @State private var allowFileBrowserOpen = true
    @State private var success = false
    
    func actionHandler(event: SetupFlowEvent) {
        handleEvent(event)
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
    
    func openProjectFiles(url: URL) -> (Result<[VibeSchema], ProjectFileError>, Result<MetaFile, ProjectFileError>)  {
        let metaFilePath = "meta.json"
        let metaFileURL = url.appending(path: metaFilePath)
        
        let animationsDirectoryFilePath = "animations"
        let animationsDirectoryURL = url.appending(path: animationsDirectoryFilePath)
        
        let meta = self.loadMetaFile(url: metaFileURL)
        let animations = self.loadAnimationFiles(url: animationsDirectoryURL)
        return (animations, meta)
    }
    
    func loadAnimationFiles(url: URL) -> Result<Array<VibeSchema>, ProjectFileError> {
        let fileManager = FileManager.default
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            let jsonFiles = fileURLs.filter { $0.pathExtension == "json" }
            
            do {
                return .success(try jsonFiles.map({ url in
                    let animationData = try Data(contentsOf: url)
                    let animationJSON = try JSONDecoder().decode(VibeSchema.self, from: animationData)
                    return animationJSON
                }))
            } catch let error {
                print(error)
                return .failure(ProjectFileError.animationFileLoad)
            }
        } catch let error {
            print(error)
            return .failure(ProjectFileError.animationDirectoryLoad)
        }
    }
    
    enum ProjectFileError: Error {
        case metaLoad
        case animationDirectoryLoad
        case animationFileLoad
    }
    
    func loadMetaFile(url: URL) -> Result<MetaFile, ProjectFileError> {
        do {
            let metaData = try Data(contentsOf: url)
            let metaJSON = try JSONDecoder().decode(MetaFile.self, from: metaData)
            return .success(metaJSON)
        } catch let error {
            print(error)
            return .failure(ProjectFileError.metaLoad)
        }
    }
    
    var body: some View {
        NavigationStack(path: navigationPath) {
            SetupFlowStartScreen(action: actionHandler)
                .navigationDestination(for: SetupFlowState.self) { currentState in
                    switch currentState {
                    case .start:
                        SetupFlowStartScreen(action: actionHandler)
                    case .browsingProject:
                        SetupFlowStartScreen(action: actionHandler)
                            .disabled(true)
                            .onAppear {
                                if allowFileBrowserOpen {
                                    openFileBrowser { url in
                                        allowFileBrowserOpen = false
                                        
                                        if let url {
                                            handleEvent(.filePicked)
                                            
                                            let result = openProjectFiles(url: url)
                                            switch result.1 {
                                            case .success(let meta):
                                                self.framework.wrappedValue = meta.framework == reactTag.rawValue ? .react : .swiftUI
                                                
                                                switch result.0 {
                                                case .success(let animations):
                                                    self.animations.wrappedValue = animations
                                                    handleEvent(.asyncJobFinished)
                                                    self.success = true
                                                case .failure(let error):
                                                    print(error)
                                                    handleEvent(.cancelSetup)
                                                    // - TODO: Show error screen
                                                }
                                                
                                            case .failure(let error):
                                                print(error)
                                                handleEvent(.cancelSetup)
                                                // - TODO: Show error screen
                                            }
                                        } else {
                                            handleEvent(.cancelSetup)
                                        }
                                    }
                                }
                            }
                            .onDisappear {
                                if !success {
                                    allowFileBrowserOpen = true
                                }
                            }
                    case .chooseFramework:
                        SetupFlowChooseFrameworkScreen { event in
                            if event == .continueSetupReact {
                                self.framework.wrappedValue = .react
                            } else if event == .continueSetupSwiftUI {
                                self.framework.wrappedValue = .swiftUI
                            }
                            
                            actionHandler(event: event)
                        }
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
                    case .swiftUIInstallImage:
                        SetupFlowInstallImageScreen(action: actionHandler)
                    case .projectLoad:
                        SetupFlowProjectLoad(action: actionHandler)
                    case .complete:
                        Text("Complete")
                            .onAppear {
                                navigationPath.wrappedValue.removeLast(navigationPath.wrappedValue.count)
                            }
                    }
            }
        }
        .environment(\.popNavigationStack, {actionHandler(event: .back)})
        .environmentObject(setupFlowManager)
    }
}
