//
//  SetupFlowProjectLoad.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 9/14/24.
//

import SwiftUI

struct SetupFlowProjectLoad: View {
    @Environment(\.appColors) var appColors: Colors
    
    let action: (SetupFlowEvent) -> Void
    
    var body: some View {
        SetupFlowBase(title: "Loading and validating") {
            VStack {
                Spacer()
                
                ProgressView()
                
                Spacer()
                
                SetupActionButton(title: "Cancel", accentColor: ColorPalette.red0) {
                    action(.cancelSetup)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
    }
}

#Preview {
    SetupFlowProjectLoad { event in
        
    }
}
