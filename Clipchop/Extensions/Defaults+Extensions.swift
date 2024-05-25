//
//  Defaults+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import Defaults

extension Defaults.Keys {
    static let timesClipped = Key<UInt>("timesClipped", default: 0)
    
    static let menuBarItemEnabled = Key<Bool>("menuBarItemEnabled", default: true)
    static let preferredColorScheme = Key<PreferredColorScheme>("preferredColorScheme", default: .system)
    
    static let beginningViewShown = Key<Bool>("beginningViewShown", default: false)
    
    // MARK: Appearance
    
    static let colorStyle = Key<ColorStyle>("colorStyle", default: .app)
    static let customAccentColor = Key<Color>("customAccentColor", default: .accentColor)
    
    static let appIcon = Key<AppIcon>("appIcon", default: .defaultAppIcon)
    static let clipSound = Key<Sound>("clipSound", default: .defaultSound)
    static let pasteSound = Key<Sound>("pasteSound", default: .defaultSound)
    
    // MARK: Excluded Applications
    
    static let excludeAppsEnabled = Key<Bool>("excludeAppsEnabled", default: true)
    static let applicationExcludeList = Key<[String]>("applicationExcludeList", default: [
        // Keychain Access
        "com.apple.keychainaccess"
    ])
    
    // MARK: Clip History
    
    static let timerInterval = Key<TimeInterval>("timerInterval", default: 0.1)
    
    static let historyPreservationPeriod = Key<HistoryPreservationPeriod>("historyPreservationPeriod", default: .forever)
    static let historyPreservationTime = Key<Double>("historyPreservationTime", default: 15)
    
    
    static let categories = Key<[String: [String]]>("categories", default: [
            "Images": ["jpg", "png", "gif"],
            "Documents": ["pdf", "docx", "xlsx", "pdf"],
            "Videos": ["mp4", "mov", "avi"],
            "Audio": ["mp3", "wav", "m4a", "Link"]
        ])
    static let uncategorizedFileTypes = Key<[String]>("uncategorizedFileTypes", default: [])
    
}

extension Defaults {
    static var accentColor: Color {
        inlineAccentColor(style: Self[.colorStyle], customColor: Self[.customAccentColor])
    }
    
    static func inlineAccentColor(style: ColorStyle, customColor: Color) -> Color {
        switch style {
        case .app:
            .accent
        case .system:
            .blue
        case .custom:
            customColor
        }
    }
    
    static func shouldIgnoreApp(_ bundleIdentifier: String) -> Bool {
        Self[.excludeAppsEnabled] && Self[.applicationExcludeList].contains(bundleIdentifier)
    }
}
