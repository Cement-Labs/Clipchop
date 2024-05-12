//
//  Defaults+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import Foundation
import Defaults
import SwiftUI

extension Defaults.Keys {
    static let timesClipped = Key<UInt>("timesClipped", default: 0)
    
    static let menuBarItemEnabled = Key<Bool>("menuBarItemEnabled", default: true)
    static let useCustomAccentColor = Key<Bool>("useCustomAccentColor", default: false)
    static let customAccentColor = Key<Color>("customAccentColor", default: .accentColor)
    
    static let appIcon = Key<Icons.Icon>("appIcon", default: Icons.defaultAppIcon)
    static let sound = Key<Sounds.Sound>("sound", default: Sounds.defaultSound)
    
    static let timerInterval = Key<TimeInterval>("timerInterval", default: 1)
    
    static let ignoreAppsEnabled = Key<Bool>("ignoreAppsEnabled", default: true)
    static let applicationExcludeList = Key<[String]>("applicationExcludeList", default: [])
    
    static let historyPreservationTime = Key<HistoryPreservationTime>("historyPreservationTime", default: .forever)
}
