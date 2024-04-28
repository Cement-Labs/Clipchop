//
//  KeyboardShortcuts+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/28.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let popup = Name("popup", default: Shortcut(.c, modifiers: [.command, .shift]))
    static let pin = Name("pin", default: Shortcut(.p, modifiers: [.option]))
    static let delete = Name("delete", default: Shortcut(.delete, modifiers: [.option]))
}
