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
        
        var fileTypes: [FileType] {
            Defaults[.fileTypes]
                .filter { $0.categories.contains(self) }
        }
        
        var fileExts: [String] {
            get {
                .init(fileTypes.map({ $0.ext }))
            }
            
            set {
                let deletion = fileExts.filter { !newValue.contains($0) }
                let addition = newValue.filter { !fileExts.contains($0) }
                
                guard deletion != addition else {
                    // No modifications
                    return
                }
                
                deletion.forEach { ext in
                    Defaults[.fileTypes]
                        .updateEach { type in
                            guard type.ext == ext else { return }
                            type.categories.removeAll { $0 == self }
                        }
                }
                
                addition.forEach { ext in
                    Defaults[.fileTypes]
                        .updateEach { type in
                            guard type.ext == ext else { return }
                            type.categories.append(self)
                        }
                }
            }
        }
    }
    
    var ext: String
    var categories: [Category] = []
    
    init(ext input: String, categories: [Category] = []) {
        self.ext = Self.trim(input: input)
        self.categories = categories
    }
    
    static func trim(input: String) -> String {
        input
            .lowercased()
            .replacing(/\s+/, with: "") // Removes all spaces
            .trimmingCharacters(in: ["."]) // Trims all prefixing & suffixing dots
    }
    
    static func isValid(input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.contains(/\s+/) // Contains whitespaces
    }
    
    static func isNew(_ ext: String) -> Bool {
        !Defaults[.fileTypes].contains(.init(ext: ext))
    }
}

extension FileType: Identifiable {
    var id: String {
        self.ext
    }
}

extension FileType: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.ext.hashValue)
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

extension FileType.Category: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id.hashValue)
    }
}
