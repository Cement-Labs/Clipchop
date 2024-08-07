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

// MARK: - KeyboardModifier

enum KeyboardModifier: String, Codable, CaseIterable, Identifiable, Defaults.Serializable {
    case none
    case control
    case command
    case option
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .none:
            return NSLocalizedString("none", comment: "none")
        case .control:
            return NSLocalizedString("control ⌃", comment: "control")
        case .command:
            return NSLocalizedString("command ⌘", comment: "command")
        case .option:
            return NSLocalizedString("option ⌥", comment: "option")
        }
    }
    
    var eventModifier: EventModifiers {
        switch self {
        case .none:
            return []
        case .control:
            return .control
        case .command:
            return .command
        case .option:
            return .option
        }
    }
}

enum KeyboardSwitcher: String, Codable, CaseIterable, Identifiable, Defaults.Serializable {
    case none
    case control
    case option
    
    var id: String { rawValue }
    
    var switcherDisplayName: String {
        switch self {
        case .none:
            return NSLocalizedString("none", comment: "none")
        case .control:
            return NSLocalizedString("control ⌃", comment: "control")
        case .option:
            return NSLocalizedString("option ⌥", comment: "option")
        }
    }
    
    var switchereventModifier: EventModifiers {
        switch self {
        case .none:
            return []
        case .control:
            return .control
        case .option:
            return .option
        }
    }
    
    var switchereventNSEvent: NSEvent.ModifierFlags {
        switch self {
        case .none:
            return []
        case .control:
            return .control
        case .option:
            return .option
        }
    }
    
    var switcherKeyCode: Int {
        switch self {
        case .none:
            return -1
        case .control:
            return 59
        case .option:
            return 58
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


// MARK: - Category

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

// MARK: -  Window position

enum CursorPosition: String, CaseIterable, Identifiable, Defaults.Serializable {
    case mouseLocation = "NSEvent.mouseLocation"
    case adjustedPosition = "Adjusted Position"
    case fixedPosition = "Fixed position"
    
    var displayText: String {
        switch self {
        case .mouseLocation:
            return NSLocalizedString("At the mouse", comment: "At the mouse")
        case .adjustedPosition:
            return NSLocalizedString("At the cursor", comment: "At the cursor")
        case .fixedPosition:
            return NSLocalizedString("At the subcenter", comment: "At the subcenter")
        }
    }
    
    var id: String { self.rawValue }
}

