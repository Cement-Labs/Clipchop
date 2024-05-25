//
//  KeyboardShortcuts+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/28.
//

import KeyboardShortcuts
import AppKit

 extension KeyboardShortcuts.Name {
     static let window = Self("window", default: .init(.v, modifiers: .option))
     static let pin = Self("pin", default: .init(.p, modifiers: .option))
     static let delete = Self("delete", default: .init(.delete, modifiers: .option))
     
     static let escape = Self("escape", default: .init(.escape))
     static let settings = Self("settings", default: .init(.comma, modifiers: .command))
     static let expand = Self("expand", default: .init(.rightBracket))
     static let collapse = Self("collapse", default: .init(.leftBracket))
 }
