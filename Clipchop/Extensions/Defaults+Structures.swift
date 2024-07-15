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

// MARK: - Color Style

enum ColorStyle: String, Defaults.Serializable {
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
