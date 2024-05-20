//
//  Defaults+Structures.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults

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

enum HistoryPreservationPeriod: String, CaseIterable, Defaults.Serializable {
    case forever = "forever"
    
    case minute = "minute"
    case hour = "hour"
    case day = "day"
    case month = "month"
    case year = "year"
}

extension HistoryPreservationPeriod: Identifiable {
    var id: Self {
        self
    }
}

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
