//
//  DefaultsStack.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/18.
//

import Foundation
import Defaults

extension [AnyHashable] {
    var combinedHashValue: Int {
        var hasher = Hasher()
        self.forEach {
            hasher.combine($0)
        }
        return hasher.finalize()
    }
}

struct DefaultsStack {
    enum Group: String, CaseIterable {
        case accentColor = "accentColor"
        case historyPreservation = "historyPreservation"
        
        var relationships: [AnyHashable] {
            switch self {
            case .accentColor:
                [Defaults[.colorStyle], Defaults[.customAccentColor]]
            case .historyPreservation:
                [Defaults[.historyPreservationPeriod], Defaults[.historyPreservationTime]]
            }
        }
        
        var hashValue: Int {
            relationships.combinedHashValue
        }
        
        var isUnchanged: Bool {
            DefaultsStack.shared.isUnchanged(self)
        }
        
        func isIdentical(comparedTo: [AnyHashable]) -> Bool {
            DefaultsStack.shared.isIdentical(self, comparedTo: comparedTo)
        }
        
        func markDirty() {
            DefaultsStack.shared.markDirty(self)
        }
    }
    
    static var shared = DefaultsStack()
    
    var hash: [Group: Int]
    
    init() {
        hash = DefaultsStack.hashAll()
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
    
    func isIdentical(_ group: Group, comparedTo: [AnyHashable]) -> Bool {
        group.hashValue == comparedTo.combinedHashValue
    }
    
    mutating func markDirty(_ group: Group) {
        hash[group] = group.hashValue
    }
}
