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
    static let clipSound = Key<Sound>("clipSound", default: .defaultClipSound)
    static let pasteSound = Key<Sound>("pasteSound", default: .defaultPasteSound)
    
    // MARK: Excluded Applications
    
    static let excludeAppsEnabled = Key<Bool>("excludeAppsEnabled", default: true)
    static let excludedApplications = Key<[String]>("excludedApplications", default: [
        // Keychain Access
        "com.apple.keychainaccess"
    ])
    
    // MARK: Clip History
    
    static let pasteToFrontmostEnabled = Key<Bool>("pasteToFrontmostEnabled", default: false)
    
    static let timerInterval = Key<TimeInterval>("timerInterval", default: 0.1)
    
    static let historyPreservationPeriod = Key<HistoryPreservationPeriod>("historyPreservationPeriod", default: .forever)
    static let historyPreservationTime = Key<Double>("historyPreservationTime", default: 15)
    
    static let categories = Key<[FileType.Category]>("categories", default: [
        .document,
        .image,
        .movie,
        .audio,
        .archive,
        .sourceCodeFile
    ])
    static let fileTypes = Key<[FileType]>("fileTypes", default: [
        .init(ext: "test", categories: [.document, .sourceCodeFile, .archive, .audio, .image, .movie]),
        
        .init(ext: "pdf",       categories: [.document]),
        .init(ext: "doc",       categories: [.document]),
        .init(ext: "docx",      categories: [.document]),
        .init(ext: "xlsx",      categories: [.document]),
        .init(ext: "key",       categories: [.document]),
        .init(ext: "pages",     categories: [.document]),
        .init(ext: "numbers",   categories: [.document]),
        .init(ext: "txt",       categories: [.document]),
        .init(ext: "rtf",       categories: [.document]),
        .init(ext: "rtfd",      categories: [.document]),
        .init(ext: "ods",       categories: [.document]),
        .init(ext: "odt",       categories: [.document]),
        .init(ext: "ppt",       categories: [.document]),
        .init(ext: "pptx",      categories: [.document]),
        .init(ext: "xls",       categories: [.document]),
        .init(ext: "csv",       categories: [.document]),
        .init(ext: "html",      categories: [.document, .sourceCodeFile]),
        .init(ext: "xml",       categories: [.document, .sourceCodeFile]),
        .init(ext: "json",      categories: [.document, .sourceCodeFile]),
        
        .init(ext: "jpg",       categories: [.image]),
        .init(ext: "jpeg",      categories: [.image]),
        .init(ext: "png",       categories: [.image]),
        .init(ext: "gif",       categories: [.image]),
        .init(ext: "bmp",       categories: [.image]),
        .init(ext: "tiff",      categories: [.image]),
        .init(ext: "svg",       categories: [.image]),
        .init(ext: "webp",      categories: [.image]),
        .init(ext: "ico",       categories: [.image]),
        .init(ext: "heic",      categories: [.image]),
        .init(ext: "ai",        categories: [.image]),
        .init(ext: "psd",       categories: [.image]),
        .init(ext: "pxd",       categories: [.image]),
        
        .init(ext: "mp4",       categories: [.movie]),
        .init(ext: "mov",       categories: [.movie]),
        .init(ext: "avi",       categories: [.movie]),
        .init(ext: "mkv",       categories: [.movie]),
        .init(ext: "wmv",       categories: [.movie]),
        .init(ext: "flv",       categories: [.movie]),
        .init(ext: "mpeg",      categories: [.movie]),
        .init(ext: "mpg",       categories: [.movie]),
        .init(ext: "m4v",       categories: [.movie]),
        .init(ext: "webm",      categories: [.movie]),
        
        .init(ext: "mp3",       categories: [.audio]),
        .init(ext: "wav",       categories: [.audio]),
        .init(ext: "m4a",       categories: [.audio]),
        .init(ext: "flac",      categories: [.audio]),
        .init(ext: "aac",       categories: [.audio]),
        .init(ext: "ogg",       categories: [.audio]),
        .init(ext: "wma",       categories: [.audio]),
        .init(ext: "alac",      categories: [.audio]),
        .init(ext: "aiff",      categories: [.audio]),
        .init(ext: "dsd",       categories: [.audio]),
        
        .init(ext: "zip",       categories: [.archive]),
        .init(ext: "rar",       categories: [.archive]),
        .init(ext: "7z",        categories: [.archive]),
        .init(ext: "tar",       categories: [.archive]),
        .init(ext: "tar.gz",    categories: [.archive]),
        .init(ext: "bz2",       categories: [.archive]),
        
        .init(ext: "swift",     categories: [.sourceCodeFile]),
        .init(ext: "objc",      categories: [.sourceCodeFile]),
        .init(ext: "h",         categories: [.sourceCodeFile]),
        .init(ext: "m",         categories: [.sourceCodeFile]),
        .init(ext: "java",      categories: [.sourceCodeFile]),
        .init(ext: "class",     categories: [.sourceCodeFile]),
        .init(ext: "py",        categories: [.sourceCodeFile]),
        .init(ext: "cpp",       categories: [.sourceCodeFile]),
        .init(ext: "c",         categories: [.sourceCodeFile]),
        .init(ext: "cs",        categories: [.sourceCodeFile]),
        .init(ext: "js",        categories: [.sourceCodeFile]),
        .init(ext: "ts",        categories: [.sourceCodeFile]),
        .init(ext: "vue",       categories: [.sourceCodeFile]),
        .init(ext: "css",       categories: [.sourceCodeFile]),
        .init(ext: "scss",      categories: [.sourceCodeFile]),
        .init(ext: "less",      categories: [.sourceCodeFile]),
        .init(ext: "php",       categories: [.sourceCodeFile]),
        .init(ext: "rb",        categories: [.sourceCodeFile]),
        .init(ext: "pl",        categories: [.sourceCodeFile]),
        .init(ext: "go",        categories: [.sourceCodeFile]),
        .init(ext: "rs",        categories: [.sourceCodeFile]),
        .init(ext: "kt",        categories: [.sourceCodeFile]),
        .init(ext: "hs",        categories: [.sourceCodeFile]),
        .init(ext: "scala",     categories: [.sourceCodeFile]),
    ])
}

extension Defaults {
    static var accentColor: Color {
        inlineAccentColor(style: Self[.colorStyle], customColor: Self[.customAccentColor])
    }
    
    static var fileExts: [String] {
        get {
            Self[.fileTypes].map({ $0.ext })
        }
        
        set {
            newValue.forEach { ext in
                let isNew = newValue.contains(ext)
                let isOld = fileExts.contains(ext)
                guard isNew || isOld else {
                    // No modifications
                    return
                }
                
                if isNew {
                    // Added
                    Self[.fileTypes].append(.init(ext: ext))
                }
                
                if isOld {
                    // Removed
                    Self[.fileTypes].removeAll { $0.ext == ext }
                }
            }
        }
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
}
