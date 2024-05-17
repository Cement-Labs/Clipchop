//
//  AppIcon.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults

struct AppIcon: Hashable, Defaults.Serializable {
    var name: String?
    var assetName: String
    var unlockThreshold: Int
    
    var image: NSImage {
        .init(named: assetName)!
    }
    
    func setAppIcon() {
        Self.setAppIcon(to: self)
    }
    
    struct Bridge: Defaults.Bridge {
        typealias Value = AppIcon
        typealias Serializable = String
        
        func serialize(_ value: AppIcon?) -> String? {
            value?.assetName
        }
        
        func deserialize(_ object: String?) -> AppIcon? {
            if let object {
                return .icons.first { $0.assetName == object }
            } else {
                return .defaultAppIcon
            }
        }
    }
    
    static let bridge = Bridge()
}

extension AppIcon {
    static let stable = AppIcon(
        name: .init(localized: "App Icon: Stable", defaultValue: "Clipchop"),
        assetName: "AppIcon-Stable",
        unlockThreshold: 0
    )
    
    static let beta = AppIcon(
        name: .init(localized: "App Icon: Beta", defaultValue: "Clipchop Beta"),
        assetName: "AppIcon-Beta",
        unlockThreshold: 0
    )
    
    static let aerugo = AppIcon(
        name: .init(localized: "App Icon: Aerugo", defaultValue: "Aerugo"),
        assetName: "AppIcon-Aerugo",
        unlockThreshold: 25
    )
}

extension AppIcon {
    static var defaultAppIcon: AppIcon {
        stable
    }
    
    static var currentAppIcon: AppIcon {
        Defaults[.appIcon]
    }
    
    static let icons: [AppIcon] = [
        stable,
        beta,
        aerugo
    ]
}

extension AppIcon {
    static var unlockedIcons: [AppIcon] {
        var returnValue: [AppIcon] = []
        for icon in icons where icon.unlockThreshold <= Defaults[.timesClipped] {
            returnValue.append(icon)
        }
        return returnValue.reversed()
    }
    
    static func setAppIcon(to icon: AppIcon) {
        print("App icon set to: \(icon.assetName)")
        Defaults[.appIcon] = icon
        refreshCurrentAppIcon()
    }
    
    static func refreshCurrentAppIcon() {
        let image = Defaults[.appIcon].image
        
        NSWorkspace.shared.setIcon(
            image,
            forFile: Bundle.main.bundlePath,
            options: []
        )
        
        NSApp.applicationIconImage = image
    }
}
