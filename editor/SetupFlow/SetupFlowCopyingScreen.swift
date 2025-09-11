//
//  SetupFlowCopyingScreen.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 9/4/24.
//

import SwiftUI

struct SetupFlowCopyingScreen: View {
    @State private var progress = 0.5
    
    let action: (SetupFlowEvent) -> Void
    
    var body: some View {
        SetupFlowBase(title: "Copying Project...") {
            VStack(spacing: 16) {
                ProgressView(value: progress)
                
                Spacer()
                SetupActionButton(title: "Cancel", accentColor: ColorPalette.red0) {
                    action(.cancelSetup)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .task {
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                progress = 1.0
                action(.asyncJobFinished)
            }
        }
    }
}

//#Preview {
//    SetupFlowCopyingScreen()
//}
