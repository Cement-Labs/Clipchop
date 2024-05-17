//
//  Icon.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults

struct Icon: Hashable, Defaults.Serializable {
    var name: String?
    var assetName: String
    var unlockThreshold: Int
    
    var image: NSImage {
        .init(named: assetName)!
    }
    
    struct Bridge: Defaults.Bridge {
        typealias Value = Icon
        typealias Serializable = String
        
        func serialize(_ value: Icon?) -> String? {
            value?.assetName
        }
        
        func deserialize(_ object: String?) -> Icon? {
            if let object {
                return .icons.first { $0.assetName == object }
            } else {
                return .defaultAppIcon
            }
        }
    }
    
    static let bridge = Bridge()
}

extension Icon {
    static let stable = Icon(
        name: .init(localized: "App Icon: Stable", defaultValue: "Clipchop"),
        assetName: "AppIcon-Stable",
        unlockThreshold: 0
    )
    
    static let beta = Icon(
        name: .init(localized: "App Icon: Beta", defaultValue: "Clipchop Beta"),
        assetName: "AppIcon-Beta",
        unlockThreshold: 0
    )
    
    static let aerugo = Icon(
        name: .init(localized: "App Icon: Aerugo", defaultValue: "Aerugo"),
        assetName: "AppIcon-Aerugo",
        unlockThreshold: 25
    )
}

extension Icon {
    static var defaultAppIcon: Icon {
        stable
    }
    
    static var currentAppIcon: Icon {
        Defaults[.appIcon]
    }
    
    static let icons: [Icon] = [
        stable,
        beta,
        aerugo
    ]
}

extension Icon {
    static var unlockedIcons: [Icon] {
        var returnValue: [Icon] = []
        for icon in icons where icon.unlockThreshold <= Defaults[.timesClipped] {
            returnValue.append(icon)
        }
        return returnValue.reversed()
    }
    
    static func setAppIcon(to icon: Icon) {
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
