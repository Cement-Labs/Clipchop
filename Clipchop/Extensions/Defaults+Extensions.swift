//
//  Defaults+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import Foundation
import Defaults

extension Defaults.Keys {
    static let menuBarItemEnabled = Key<Bool>("menuBarItemEnabled", default: true)
    
    static let enabledPasteboardTypes = Key<Set<NSPasteboard.PasteboardType>>("enabledPasteboardTypes", default: Clipboard.shared.supp)
}
