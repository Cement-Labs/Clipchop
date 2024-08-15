//
//  AppDelegate.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import AppKit
import Defaults
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    
    static var isActive: Bool = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        UNUserNotificationCenter.current().delegate = self
        AppDelegate.requestNotificationAuthorization()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApp.setActivationPolicy(.accessory)
        LuminareManager.fullyClose()
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        LuminareManager.open()
        return true
    }
}
