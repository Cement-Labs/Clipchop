//
//  Color+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/14.
//

import SwiftUI
import Defaults

extension Color {
    static var appAccentColor: Color {
        Defaults[.useCustomAccentColor] ? Defaults[.customAccentColor] : .accentColor
    }
}
