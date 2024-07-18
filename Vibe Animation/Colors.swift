//
//  Colors.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 7/17/24.
//

import SwiftUI

struct ColorPalette {
    static let black = Color.black
    static let white = Color.white
    static let gray0 = Color(red: 24 / 255.0, green: 24 / 255.0, blue: 24 / 255.0)
    static let gray1 = Color(red: 220 / 255.0, green: 220 / 255.0, blue: 220 / 255.0)
}

protocol Colors {
    var backgroundPrimary: Color { get }
    var backgroundSecondary: Color { get }
}

struct ColorsDark: Colors {
    let backgroundPrimary = ColorPalette.gray0
    let backgroundSecondary = ColorPalette.black
}

struct ColorsLight: Colors {
    let backgroundPrimary = ColorPalette.white
    let backgroundSecondary = ColorPalette.gray1
}
