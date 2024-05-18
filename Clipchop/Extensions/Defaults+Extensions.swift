//
//  Defaults+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import Foundation
import Defaults
import SwiftUI

extension Defaults.Keys {
    static let timesClipped = Key<UInt>("timesClipped", default: 0)
    
    static let menuBarItemEnabled = Key<Bool>("menuBarItemEnabled", default: true)
    static let useCustomAccentColor = Key<Bool>("useCustomAccentColor", default: false)
    static let useSystemAccentColor = Key<Bool>("useSystemAccentColor", default: true)
    static let customAccentColor = Key<Color>("customAccentColor", default: .accentColor)
    
    static let appIcon = Key<AppIcon>("appIcon", default: .defaultAppIcon)
    static let clipSound = Key<Sound>("clipSound", default: .defaultSound)
    static let pasteSound = Key<Sound>("pasteSound", default: .defaultSound)
    
    static let timerInterval = Key<TimeInterval>("timerInterval", default: 0.1)
    
    static let excludeAppsEnabled = Key<Bool>("excludeAppsEnabled", default: true)
    static let applicationExcludeList = Key<[String]>("applicationExcludeList", default: [])
    
    static let historyPreservationPeriod = Key<HistoryPreservationPeriod>("historyPreservationPeriod", default: .forever)
    static let historyPreservationTime = Key<Double>("historyPreservationTime", default: 15)
}

extension Defaults {
    static var accentColor: Color {
        inlineAccentColor(useCustom: Self[.useCustomAccentColor], useSystem: Self[.useSystemAccentColor], customColor: Self[.customAccentColor])
    }
    
    static func inlineAccentColor(useCustom: Bool, useSystem: Bool, customColor: Color) -> Color {
        if !useCustom {
            // Use the color defined in Asset Catalog
            return .accent
        } else {
            if useSystem {
                // Use the color chosen for macOS
                return .init(nsColor: .controlAccentColor)
            } else {
                // Use the customized color
                return customColor
            }
        }
    }
    
    static func shouldIgnoreApp(_ bundleIdentifier: String) -> Bool {
        Self[.excludeAppsEnabled] && Self[.applicationExcludeList].contains(bundleIdentifier)
    }
}
