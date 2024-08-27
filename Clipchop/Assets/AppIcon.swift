//
//  AppIcon.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults
import UserNotifications
import Intents

struct AppIcon: Hashable, Defaults.Serializable {
    var name: String?
    var assetName: String
    var unlockThreshold: Int
    var unlockMessage: String?
    
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
        unlockThreshold: 25,
        unlockMessage: .init(localized: "Aerugo", defaultValue: "\(Bundle.main.appName) will rust if you don't clip soon.")
    )
    
    static let holoGram = AppIcon(
        name: .init(localized: "App Icon: HoloGram", defaultValue: "HoloGram"),
        assetName: "AppIcon-HoloGram",
        unlockThreshold: 50,
        unlockMessage: .init(localized: "HoloGram", defaultValue: "\(Bundle.main.appName) feels a lot stronger!")
    )
}

extension AppIcon {
    static var defaultAppIcon: AppIcon {
        #if DEBUG
        return beta
        #else
        return stable
        #endif
    }
    
    static var currentAppIcon: AppIcon {
        Defaults[.appIcon]
    }
    
    static let icons: [AppIcon] = [
        stable,
        beta,
        aerugo,
        holoGram
    ]
}

extension AppIcon {
    static var unlockedAppIcons: [AppIcon] {
        var returnValue: [AppIcon] = []
        for icon in icons where icon.unlockThreshold <= Defaults[.timesClipped] {
            returnValue.append(icon)
        }
        return returnValue.reversed()
    }
    
    static func setAppIcon(to icon: AppIcon) {
        log(self, "App icon set to: \(icon.assetName)")
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

extension AppIcon {
    static func checkIfUnlockedNewIcon() {
        guard Defaults[.sendNotification] else { return }
        
        for icon in icons where icon.unlockThreshold == Defaults[.timesClipped] {
            let title = Bundle.main.appName
            let body = icon.unlockMessage ?? "You've unlocked a new icon: \(icon.name ?? "Unknown")!"
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            
            if let imageData = NSImage(named: icon.assetName)?.tiffRepresentation,
               let attachment = UNNotificationAttachment.create(NSData(data: imageData)) {
                content.attachments = [attachment]
                content.userInfo = ["icon": icon.assetName]
            }
            
            content.categoryIdentifier = "icon_unlocked"
            
            AppDelegate.sendNotification(content)
        }
    }
}
