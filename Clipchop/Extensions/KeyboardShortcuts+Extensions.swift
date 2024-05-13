//
//  KeyboardShortcuts+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/28.
//

import Foundation
import KeyboardShortcuts
import AppKit

 extension KeyboardShortcuts.Name {
     static let action = Self("action", default: Shortcut(.v, modifiers: [.option]))
     static let pin = Self("pin", default: Shortcut(.p, modifiers: [.option]))
     static let delete = Self("delete", default: Shortcut(.delete, modifiers: [.option]))
 }
