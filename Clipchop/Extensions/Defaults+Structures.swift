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
    case system
    case light
    case dark
    
    var displayName: String {
        switch self {
        case .system:
            return NSLocalizedString("System", comment: "System")
        case .light:
            return NSLocalizedString("Light", comment: "Light")
        case .dark:
            return NSLocalizedString("Dark", comment: "Dark")
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        default: .none
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

extension HistoryPreservationPeriod {
    func localizedKey(for time: Int) -> String {
        switch self {
        case .forever:
            return "Forever"
        case .minute:
            return "\(time) Minutes"
        case .hour:
            return "\(time) Hours"
        case .day:
            return "\(time) Days"
        case .month:
            return "\(time) Months"
        case .year:
            return "\(time) Years"
        }
    }
}

// MARK: - Color Style

enum ColorStyle: String, Defaults.Serializable, CaseIterable {
    case app
    case system
    case custom
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

// MARK: Window position

enum CursorPosition: String, CaseIterable, Identifiable, Defaults.Serializable {
    case mouseLocation = "NSEvent.mouseLocation"
    case adjustedPosition = "Adjusted Position"
    
    var displayText: String {
        switch self {
        case .mouseLocation:
            return NSLocalizedString("At the mouse", comment: "At the mouse")
        case .adjustedPosition:
            return NSLocalizedString("At the cursor", comment: "At the cursor")
        }
    }
    
    var id: String { self.rawValue }
}

