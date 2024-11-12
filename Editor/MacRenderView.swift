//
//  MacRenderView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/24/24.
//

import SwiftUI
import Virtualization

struct MacRenderView: View {
    let virtualMachine: VZVirtualMachine
    let size: CGSize
    
    var body: some View {
        VirtualMachineView(virtualMachine: virtualMachine, size: CGSize(width: size.width, height: size.height))
    }
}

