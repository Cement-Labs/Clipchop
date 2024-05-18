//
//  DefaultsStack.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/18.
//

import Foundation
import Defaults

struct DefaultsStack {
    enum Group: String, CaseIterable {
        case accentColor = "accentColor"
        
        var relationships: [AnyHashable] {
            switch self {
            case .accentColor:
                [Defaults[.useCustomAccentColor], Defaults[.useSystemAccentColor], Defaults[.customAccentColor]]
            }
        }
        
        var hashValue: Int {
            var hasher = Hasher()
            self.relationships.forEach {
                hasher.combine($0)
            }
            return hasher.finalize()
        }
    }
    
    static let shared = DefaultsStack()
    
    let hash: [Group: Int]
    let date: Date
    
    init() {
        hash = DefaultsStack.hashAll()
        date = .now
    }
    
    static func hashAll(_ groups: [Group] = Group.allCases) -> [Group: Int] {
        groups.reduce(into: [Group: Int]()) { result, group in
            result[group] = group.hashValue
        }
    }
    
    func isUnchanged(_ group: Group) -> Bool {
        guard let hashed = hash[group] else { return false }
        return hashed == group.hashValue
    }
}
