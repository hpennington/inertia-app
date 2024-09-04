//
//  SetupFlowConfigrationWebScreen.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/3/24.
//

import SwiftUI

struct SetupFlowConfigurationWebScreen: View {
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

#Preview {
    SetupFlowConfigurationWebScreen(title: .constant("Title"), serverURL: .constant("url"))
}
