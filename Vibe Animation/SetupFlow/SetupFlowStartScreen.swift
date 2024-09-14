//
//  SetupFlowStartScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/28/24.
//

import Combine
import SwiftUI
import Vibe

typealias Tag = SetupFlowFramework
let reactTag = SetupFlowFramework.react
let swiftUITag = SetupFlowFramework.swiftUI

struct SetupFlowStartScreen: View {
    @Environment(\.appColors) var appColors: Colors
    
    let action: (SetupFlowEvent) -> Void
    private let buttonVPadding = 8.0
    
    @State private var dialogOpen = false
    
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
                break
            }
            
            dialogOpen = false
        }
        dialogOpen = true
    }
        
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
                        openFileBrowser { url in
                            if let url {
                                action(.openProject(url: url))
                            }
                        }
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
        .disabled(dialogOpen)
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
    
    func openProjectFiles(url: URL) -> Bool {
        let metaFilePath = "meta.json"
        let metaFileURL = url.appending(path: metaFilePath)
        
        let animationsDirectoryFilePath = "animations"
        let animationsDirectoryURL = url.appending(path: animationsDirectoryFilePath)
        
        let meta = self.loadMetaFile(url: metaFileURL)
        print(meta)
        let animations = self.loadAnimationFiles(url: animationsDirectoryURL)
        print(animations)
        
        self.stateMachine.handleEvent(.asyncJobFinished)
        return true
    }
    
    func handleEvent(_ event: SetupFlowEvent) {
        self.event = event
        stateMachine.handleEvent(event)
        
        switch event {
        case .openProject(let url):
            openProjectFiles(url: url)
        default:
            break
        }
    }
}
