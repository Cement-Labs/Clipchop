//
//  Defaults+Structures.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults

// MARK: - Preferred Color Scheme

enum PreferredColorScheme: String, CaseIterable, Codable, Defaults.Serializable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        default: .none
        }
    }
    
    var needsReload: Bool {
        switch self {
        case .system: true
        default: false
        }
    }
}

// MARK: - History Preservation Period

enum HistoryPreservationPeriod: String, CaseIterable, Defaults.Serializable {
    case forever = "forever"
    
    case minute = "minute"
    case hour = "hour"
    case day = "day"
    case month = "month"
    case year = "year"
    
    @ViewBuilder
    func withTime(_ time: Int) -> some View {
        switch self {
        case .forever: Text("Forever")
        case .minute:
            Text("\(time) Minutes")
        case .hour:
            Text("\(time) Hours")
        case .day:
            Text("\(time) Days")
        case .month:
            Text("\(time) Months")
        case .year:
            Text("\(time) Years")
        }
    }
}

extension HistoryPreservationPeriod: Identifiable {
    var id: Self {
        self
    }
}

// MARK: - Color Style

enum ColorStyle: Int, CaseIterable, Defaults.Serializable {
    case app = 0
    case system = 1
    case custom = 2
}

extension ColorStyle: Identifiable {
    var id: Self {
        self
    }
}

// MARK: Category

struct FileType: Codable, Defaults.Serializable {
    var ext: String
    var categories: [Category] = []
    
    struct Category: Identifiable, Codable, Defaults.Serializable {
        var id: UUID = .init()
        var name: String
        
        // Default provided categories
        static let document =       FileType.Category(name: .init(localized: "Document"))
        static let image =          FileType.Category(name: .init(localized: "Image"))
        static let movie =          FileType.Category(name: .init(localized: "Movie"))
        static let audio =          FileType.Category(name: .init(localized: "Audio"))
        static let archive =        FileType.Category(name: .init(localized: "Archive"))
        static let sourceCodeFile = FileType.Category(name: .init(localized: "Source Code File"))
    }
}

extension FileType: Identifiable {
    var id: String {
        self.ext
    }
}

extension FileType: Equatable {
    static func ==(lhs: FileType, rhs: FileType) -> Bool {
        lhs.ext == rhs.ext
    }
}

extension FileType.Category: Equatable {
    static func ==(lhs: FileType.Category, rhs: FileType.Category) -> Bool {
        lhs.id == rhs.id
    }
}
