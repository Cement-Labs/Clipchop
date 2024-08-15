//
//  Color+Extensions.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/6.
//

import SwiftUI
import Defaults

extension Color {
    static func getAccent() -> Color {
        return inlineAccentColor(style: Defaults[.colorStyle], customColor: Defaults[.customAccentColor])
    }
    
    static func inlineAccentColor(style: ColorStyle, customColor: Color) -> Color {
        switch style {
        case .app:
            return .accent
        case .system:
            return .blue
        case .custom:
            return customColor
        }
    }
}

extension Color {
    var brightness: Double {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return 0
        }
        let red = Double(components[0] * 255)
        let green = Double(components[1] * 255)
        let blue = Double(components[2] * 255)
        return (red * 299 + green * 587 + blue * 114) / 1000
    }

    var isLight: Bool {
        return brightness > 128
    }
}
