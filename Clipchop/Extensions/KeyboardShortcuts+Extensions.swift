//
//  KeyboardShortcuts+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/28.
//

import KeyboardShortcuts
import AppKit

extension KeyboardShortcuts.Name {
    
    static let window = Self("window", default: .init(.w, modifiers: .option))
    static let start = Self("start", default: .init(.q, modifiers: .control))
    
    static let settings = Self("settings", default: .init(.comma, modifiers: .command))
    static let expand = Self("expand", default: .init(.rightBracket))
    static let collapse = Self("collapse", default: .init(.leftBracket))
}

extension KeyboardShortcuts.Key {
    var shortcut: KeyboardShortcuts.Shortcut {
        .init(self)
    }
}
