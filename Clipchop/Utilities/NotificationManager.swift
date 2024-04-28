//
//  NotificationManager.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/28.
//

import Foundation
import AppKit
import UserNotifications

class NotificationManager {
    private static var center: UNUserNotificationCenter { UNUserNotificationCenter.current() }
    
    static func authorize() {
        center.requestAuthorization(options: [.alert, .sound]) { _, error in
            if error != nil {
                NSLog("Failed to authorize notifications: \(String(describing: error))")
            }
        }
    }
    
    static func notify(body: String?, sound: NSSound?) {
        guard let body else { return }
        
        authorize()
        
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                    (settings.authorizationStatus == .provisional) else { return }
            
            let content = UNMutableNotificationContent()
            if settings.alertSetting == .enabled {
                content.body = body
            }
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            center.add(request) { error in
                if error != nil {
                    NSLog("Failed to deliver notification: \(String(describing: error))")
                } else {
                    if settings.soundSetting == .enabled {
                        sound?.play()
                    }
                }
            }
        }
    }
}

