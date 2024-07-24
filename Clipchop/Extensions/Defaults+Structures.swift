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
<<<<<<< HEAD
    case system = "system"
    case light = "light"
    case dark = "dark"
=======
    case system
    case light
    case dark
>>>>>>> origin/rewrite/main
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        default: .none
        }
    }
<<<<<<< HEAD
    
    var needsReload: Bool {
        switch self {
        case .system: true
        default: false
        }
    }
=======
>>>>>>> origin/rewrite/main
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

<<<<<<< HEAD
enum ColorStyle: Int, CaseIterable, Defaults.Serializable {
    case app = 0
    case system = 1
    case custom = 2
}

extension ColorStyle: Identifiable {
    var id: Self {
        self
    }
=======
enum ColorStyle: String, Defaults.Serializable {
    case app
    case system
    case custom
>>>>>>> origin/rewrite/main
}

// MARK: Category

struct FileCategory: Hashable, Identifiable, Codable, Defaults.Serializable {
        var id: UUID = .init()
        var name: String = ""
        var types: [String] = []

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func ==(lhs: FileCategory, rhs: FileCategory) -> Bool {
        lhs.id == rhs.id
    }
}
<<<<<<< HEAD
=======

// MARK: Window position

enum CursorPosition: String, CaseIterable, Identifiable, Defaults.Serializable {
    case mouseLocation = "NSEvent.mouseLocation"
    case adjustedPosition = "Adjusted Position"
    
    var id: String { self.rawValue }
}

>>>>>>> origin/rewrite/main
