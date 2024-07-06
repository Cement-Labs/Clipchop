//
//  IconManager.swift
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
