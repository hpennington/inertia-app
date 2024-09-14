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
    static let accentTheme = Color(red: 78 / 255.0, green: 55 / 255.0, blue: 108 / 255.0)
    static let gray0 = Color(red: 24 / 255.0, green: 24 / 255.0, blue: 24 / 255.0)
    static let gray1 = Color(red: 51 / 255.0, green: 49 / 255.0, blue: 59 / 255.0)
    static let gray2 = Color(red: 71 / 255.0, green: 69 / 255.0, blue: 79 / 255.0)
    static let gray3 = Color(red: 101 / 255.0, green: 99 / 255.0, blue: 109 / 255.0)
    static let gray4 = Color(red: 121 / 255.0, green: 119 / 255.0, blue: 129 / 255.0)
    static let gray5 = Color(red: 221 / 255.0, green: 219 / 255.0, blue: 229 / 255.0)
    static let red0 = Color(red: 250 / 255.0, green: 82 / 255.0, blue: 82 / 255.0)
}

protocol Colors {
    var accent: Color { get }
    var backgroundPrimary: Color { get }
    var backgroundSecondary: Color { get }
}

struct ColorsDark: Colors {
    let accent = ColorPalette.accentTheme
    let backgroundPrimary = ColorPalette.gray0
    let backgroundSecondary = ColorPalette.black
}

struct ColorsLight: Colors {
    let accent = ColorPalette.accentTheme
    let backgroundPrimary = ColorPalette.white
    let backgroundSecondary = ColorPalette.gray3
}
