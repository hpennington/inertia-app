//
//  MacRenderView.swift
//  Inertia Animation
//
//  Created by Hayden Pennington on 7/24/24.
//

import SwiftUI
import Virtualization

struct MacRenderView: View {
    let virtualMachine: VZVirtualMachine
    let paths: VirtualMachinePaths
    let size: CGSize
    
    var body: some View {
        VirtualMachineView(virtualMachine: virtualMachine, paths: paths, size: CGSize(width: size.width, height: size.height))
    }
}

