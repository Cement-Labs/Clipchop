//
//  PerimissionsManager.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import Foundation
import AppKit
import FullDiskAccess

class PermissionsManager {
    static func requestAccess() {
        PermissionsManager.Accessibility.requestAccess()
    }
    
    class Accessibility {
        static func getStatus() -> Bool {
            // Get current status for Accessibility Access
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: false]
            let status = AXIsProcessTrustedWithOptions(options)
            
            return status
        }
        
        @discardableResult
        static func requestAccess() -> Bool {
            // More information on this behaviour: https://stackoverflow.com/questions/29006379/accessibility-permissions-reset-after-application-update
            guard !Accessibility.getStatus() else { return true }
            
            let alert = NSAlert()
            alert.alertStyle = NSAlert.Style.informational
            alert.messageText = String(
                format: String(localized: .init(
                    "Accessibility Access Alert: Title",
                    defaultValue: "%@ Needs Accessibility Access"
                )),
                Bundle.main.appName
            )
            alert.informativeText = String(
                format: String(localized: .init(
                    "Accessibility Access Alert: Content",
                    defaultValue: """
Accessibility Access is required for %@ to take over your clipboard. No data will be collected remotely.
"""
                )),
                Bundle.main.appName
            )
            
            alert.runModal()
            
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
            let status = AXIsProcessTrustedWithOptions(options)
            
            return status
        }
    }
    
    class FullDisk {
        static func getStatus() -> Bool {
            // Get current status for Full Disk Access
            return FullDiskAccess.isGranted
        }
        
        @discardableResult
        static func requestAccess() -> Bool {
            guard !FullDisk.getStatus() else { return true }
            
            FullDiskAccess.promptIfNotGranted(
                title: String(
                    format: String(localized: .init(
                        "Full Disk Access Alert: Title",
                        defaultValue: "%@ Needs Full Disk Access"
                    )),
                    Bundle.main.appName
                ),
                message: String(
                    format: String(localized: .init(
                        "Full Disk Access Alert: Content",
                        defaultValue: """
Full Disk Access is required for %@ to generate file previews. No data will be collected remotely.
"""
                    )),
                    Bundle.main.appName
                ),
                settingsButtonTitle: String(localized: .init("Open Settings", defaultValue: "Open Settings")),
                skipButtonTitle: String(localized: .init("Later", defaultValue: "Later")),
                canBeSuppressed: false,
                icon: nil
            )
            
            return getStatus()
        }
    }
}
