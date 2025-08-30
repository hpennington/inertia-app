//
//  SettingsIcon.swift
//  Inertia
//
//  Created by Hayden Pennington on 8/30/25.
//

import SwiftUI

public struct SettingsIconButton: View {
    let action: () -> Void
    
    public var body: some View {
        Button(action: action, label: {
            Image(systemName: "gear.circle")
                .resizable()
                .renderingMode(.template)
                .padding(2)
                .frame(width: 24, height: 24)
        })
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
    }
}
