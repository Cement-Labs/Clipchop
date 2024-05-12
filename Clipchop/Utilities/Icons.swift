//
//  Icons.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults

class Icons: ObservableObject {
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
            
            func serialize(_ value: Icons.Icon?) -> String? {
                value?.assetName
            }
            
            func deserialize(_ object: String?) -> Icons.Icon? {
                if let object {
                    return Icons.icons.first(where: { $0.assetName == object })
                } else {
                    return Icons.defaultAppIcon
                }
            }
        }
        
        static let bridge = Bridge()
    }
    
    static var defaultAppIcon: Icon {
        icons.first!
    }
    
    static var currentAppIcon: Icon {
        Defaults[.appIcon]
    }
    
    static let icons: [Icon] = [
        Icon(
            name: .init(localized: .init("App Icon: Stable", defaultValue: "Clipchop")),
            assetName: "AppIcon-Public",
            unlockThreshold: 0
        ),
        Icon(
            name: .init(localized: .init("App Icon: Beta", defaultValue: "Clipchop Beta")),
            assetName: "AppIcon-Beta",
            unlockThreshold: 0
        ),
        Icon(
            name: .init(localized: .init("App Icon: Aerugo", defaultValue: "Aerugo")),
            assetName: "AppIcon-Aerugo",
            unlockThreshold: 25
        )]
    
    static func returnUnlockedIcons() -> [Icon] {
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
    
    static func setAppIcon(to iconName: String) {
        if let targetIcon = icons.first(where: { $0.assetName == iconName }) {
            setAppIcon(to: targetIcon)
        }
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
