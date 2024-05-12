//
//  Defaults+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import Foundation
import Defaults

extension Defaults.Keys {
    static let timesClipped = Key<UInt>("timesClipped", default: 0)
    
    static let menuBarItemEnabled = Key<Bool>("menuBarItemEnabled", default: true)
    static let accentColor = Key<AccentColor>("accentColor", default: .system)
    
    static let appIcon = Key<Icons.Icon>("appIcon", default: Icons.defaultAppIcon)
    static let sound = Key<Sounds.Sound>("sound", default: Sounds.defaultSound)
}
