//
//  Defaults+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import Defaults

extension Defaults.Keys {
    
    // MARK: BeginningView
    static let beginningViewShown = Key<Bool>("beginningViewShown", default: false)
    
    // MARK: Panel
    static let displayMore = Key<Bool>("displayMore", default: false)
    static let cardPreviewMoreView = Key<Bool>("cardPreviewMoreView", default: false)
    static let menuBarItemEnabled = Key<Bool>("menuBarItemEnabled", default: true)
    static let cursorPosition = Key<CursorPosition>("cursorPosition", default: .mouseLocation)
    
    // MARK: Appearance
    static let timesClipped = Key<UInt>("timesClipped", default: 0)
    
    static let colorStyle = Key<ColorStyle>("colorStyle", default: .app)
    static let customAccentColor = Key<Color>("customAccentColor", default: .accentColor)
    static let preferredColorScheme = Key<PreferredColorScheme>("preferredColorScheme", default: .system)
    
    static let dnd = Key<Bool>("dnd", default: false)
    static let appIcon = Key<AppIcon>("appIcon", default: .defaultAppIcon)
    static let clipSound = Key<Sound>("clipSound", default: .defaultClipSound)
    static let pasteSound = Key<Sound>("pasteSound", default: .defaultPasteSound)
    
    // MARK: Excluded Applications
    
    static let excludeAppsEnabled = Key<Bool>("excludeAppsEnabled", default: true)
    static let excludedApplications = Defaults.Key<[String]>("excludedApplications", default: {
        if #available(macOS 15, *) {
            return [
                "com.apple.Passwords"
            ]
        } else {
            return [
                "com.apple.keychainaccess"
            ]
        }
    }())
    
    // MARK: KeyboardModifier
    
    static let deleteShortcut = Defaults.Key<KeyboardModifier>("deleteShortcut", default: .control)
    static let copyShortcut = Defaults.Key<KeyboardModifier>("copyShortcut", default: .command)
    static let pinShortcut = Defaults.Key<KeyboardModifier>("pinShortcut", default: .option)
    
    static let keySwitcher = Defaults.Key<KeyboardSwitcher>("keySwitcher", default: .option)
    
    // MARK: Clip History
    
    static let autoCloseTimeout = Key<TimeInterval>("autoCloseTimeout", default: 60)
    static let clipboardMonitoring = Key<Bool>("clipboardMonitoring", default: false)
    
    static let pasteToFrontmostEnabled = Key<Bool>("pasteToFrontmostEnabled", default: true)
    
    static let removeFormatting = Key<Bool>("removeFormatting", default: false)
    
    static let timerInterval = Key<TimeInterval>("timerInterval", default: 0.5)
    
    static let historyPreservationPeriod = Key<HistoryPreservationPeriod>("historyPreservationPeriod", default: .day)
    static let historyPreservationTime = Key<Double>("historyPreservationTime", default: 15)
    
    static let categories = Key<[FileCategory]>("categories", default: [
        
        .init(name: .init(localized: "Images", defaultValue: "Images"), types: [
            "jpg", "png", "gif", "jpeg", "bmp", "tiff", "svg", "webp", "ico", "heic",  NSLocalizedString("images", comment: "images")
        ].map { $0.lowercased() }),
        
        .init(name: .init(localized: "Documents", defaultValue: "Documents"), types: [
            "pdf", "docx", "xlsx",
            "key", "pages", "numbers",
            "txt", "rtf", "rtfd",
            "doc", "ods", "odt", "pptx", "ppt", "xls", "csv", "html", "xml", "json"
        ].map { $0.lowercased() }),
        
        .init(name: .init(localized: "Videos", defaultValue: "Videos"), types: [
            "mp4", "mov", "avi",
            "mkv", "wmv", "flv", "mpeg", "mpg", "m4v", "webm"
        ].map { $0.lowercased() }),
        
        .init(name: .init(localized: "Audio", defaultValue: "Audio"), types: [
            "mp3", "wav", "m4a", "flac",
            "aac", "ogg", "wma", "alac", "aiff", "dsd"
        ].map { $0.lowercased() }),
        
        .init(name: .init(localized: "Archives", defaultValue: "Archives"), types: [
            "zip", "rar", "7z", "tar", "gz", "bz2"
        ].map { $0.lowercased() }),
        
        .init(name: .init(localized: "Code Files", defaultValue: "Code Files"), types: [
            "swift", "objc", "java", "py", "cpp", "cs", "js", "ts", "html", "css", "scss", "less", "php", "rb", "pl", "go", "rs", "kt"
        ].map { $0.lowercased() }),
        
        .init(name: .init(localized: "3D Models", defaultValue: "3D Models"), types: [
            "obj", "fbx", "dae", "stl", "3ds", "blend", "max", "ma", "mb", "dwg", "dxf", "skp", "step", "iges", "stp", "3dm",
            "usd", "usda", "usdc", "usdz"
        ].map { $0.lowercased() }),
        
        .init(name: .init(localized: "Link", defaultValue: "Link"), types: [
            NSLocalizedString("link", comment: "link")
        ].map { $0.lowercased() }),
        
        .init(name: .init(localized: "Color", defaultValue: "Color"), types: [
            NSLocalizedString("color", comment: "color")
        ].map { $0.lowercased() })
        
    ])

    static let allTypes = Key<[String]>("allTypes", default: categories.defaultValue.flatMap { $0.types })
    
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
        Self[.excludeAppsEnabled] && Self[.excludedApplications].contains(bundleIdentifier)
    }
    
    static func isValidFileTypeInput(_ type: String) -> Bool {
        !type
            .trimmingCharacters(in: [".", " "])
            .contains(/(\.|\s+)/)
    }
    
    static func isNewFileTypeInput(_ type: String) -> Bool {
        !Self[.allTypes].contains(trimFileTypeInput(type))
    }
    
    static func trimFileTypeInput(_ type: String) -> String {
        type
            .lowercased()
            .replacing(/(\.|\s+)/, with: "")
    }
    
    static func removeFileTypeFromAll(_ type: String) {
        Self[.allTypes].removeAll { $0 == type }
        Self[.categories].updateEach { category in
            category.types.removeAll { $0 == type }
        }
    }
}
