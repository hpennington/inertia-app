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
    static let purple0 = Color(red: 142 / 255.0, green: 89 / 255.0, blue: 255 / 255.0)
    static let gray0 = Color(red: 24 / 255.0, green: 24 / 255.0, blue: 24 / 255.0)
    static let gray1 = Color(red: 68 / 255.0, green: 68 / 255.0, blue: 68 / 255.0)
    static let gray2 = Color(red: 99 / 255.0, green: 99 / 255.0, blue: 99 / 255.0)
    static let gray3 = Color(red: 220 / 255.0, green: 220 / 255.0, blue: 220 / 255.0)
}

protocol Colors {
    var accent: Color { get }
    var backgroundPrimary: Color { get }
    var backgroundSecondary: Color { get }
}

struct ColorsDark: Colors {
    let accent = ColorPalette.purple0
    let backgroundPrimary = ColorPalette.gray0
    let backgroundSecondary = ColorPalette.black
}

struct ColorsLight: Colors {
    let accent = ColorPalette.purple0
    let backgroundPrimary = ColorPalette.white
    let backgroundSecondary = ColorPalette.gray3
}
