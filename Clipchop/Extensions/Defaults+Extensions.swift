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
    
    static let paste = Key<Bool>("paste", default: false)
    
    static let timerInterval = Key<TimeInterval>("timerInterval", default: 0.1)
    
    static let historyPreservationPeriod = Key<HistoryPreservationPeriod>("historyPreservationPeriod", default: .forever)
    static let historyPreservationTime = Key<Double>("historyPreservationTime", default: 15)
    
    static let categories = Key<[FileCategory]>("categories", default: [
        .init(name: .init(localized: "Images", defaultValue: "Images"), types: [
            "jpg", "png", "gif", "jpeg", "bmp", "tiff", "svg", "webp", "ico", "heic"
        ]),
        .init(name: .init(localized: "Documents", defaultValue: "Documents"), types: [
            "pdf", "docx", "xlsx",
            "key", "pages", "numbers",
            "txt", "rtf", "rtfd",
            "doc", "ods", "odt", "pptx", "ppt", "xls", "csv", "html", "xml", "json"
        ]),
        .init(name: .init(localized: "Videos", defaultValue: "Videos"), types: [
            "mp4", "mov", "avi",
            "mkv", "wmv", "flv", "mpeg", "mpg", "m4v", "webm"
        ]),
        .init(name: .init(localized: "Audio", defaultValue: "Audio"), types: [
            "mp3", "wav", "m4a", "flac",
            "aac", "ogg", "wma", "alac", "aiff", "dsd"
        ]),
        
        .init(name: .init(localized: "Archives", defaultValue: "Archives"), types: [
            "zip", "rar", "7z", "tar", "gz", "bz2"
        ]),
        
        .init(name: .init(localized: "Code", defaultValue: "Code Files"), types: [
            "swift", "objc", "java", "py", "cpp", "cs", "js", "ts", "html", "css", "scss", "less", "php", "rb", "pl", "go", "rs", "kt"
        ])
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
        Self[.excludeAppsEnabled] && Self[.applicationExcludeList].contains(bundleIdentifier)
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
