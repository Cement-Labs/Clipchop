//
//  AppDelegate.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import Foundation
import AppKit
import Defaults

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        PermissionsManager.requestAccess()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApp.setActivationPolicy(.accessory)
        return false
    }
}
