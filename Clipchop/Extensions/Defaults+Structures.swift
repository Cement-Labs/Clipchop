//
//  Defaults+Structures.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults

enum AccentColor: Defaults.Serializable {
    case system
    case custom(Color)
    
    struct Bridge: Defaults.Bridge {
        typealias Value = AccentColor
        typealias Serializable = Any
        
        func serialize(_ value: AccentColor?) -> Any? {
            if let value {
                return switch value {
                case .system: []
                case .custom(let color): Color.bridge.serialize(color)
                }
            } else {
                return []
            }
        }
        
        func deserialize(_ object: Any?) -> AccentColor? {
            if let object = object as? [Any] {
                if object.isEmpty {
                    return .system
                } else {
                    if let color = Color.bridge.deserialize(object) {
                        return .custom(color)
                    } else {
                        return .system
                    }
                }
            } else {
                return .system
            }
        }
    }
    
    static let bridge = Bridge()
}
