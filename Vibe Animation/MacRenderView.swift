//
//  MacRenderView.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/24/24.
//

import SwiftUI

struct MacRenderView: View {
    let size: CGSize
    
    var body: some View {
        VirtualMachineView(size: CGSize(width: size.width * 3, height: size.height * 3))
    }
}

