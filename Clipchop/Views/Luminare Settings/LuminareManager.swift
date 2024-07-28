//
//  LuminareManager.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/26.
//

import Luminare
import SFSafeSymbols
import SwiftUI

class LuminareManager: ObservableObject {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var apps: InstalledApps
    
    @Published var appExcluding: SettingsTab
    
    static let shared = LuminareManager()
    
    private init() {
        // Initialize appExcluding with a placeholder; will be updated later
        appExcluding = SettingsTab("App Excluding", Image(systemSymbol: .xmarkSeal), LuminareExcludedAppsSettings())
    }
    
    static let generalSettingsPage = SettingsTab("General", Image(systemSymbol: .gearshape), LuminareGeneralSettings())
    static let customizationSettingsPage = SettingsTab("Customization", Image(systemSymbol: .pencilAndOutline), LuminareCustomizationSettings())
    static let clipboardSettingsPage = SettingsTab("Clipboard", Image(systemSymbol: .clipboard), LuminareClipboardSettings(clipboardController: ClipboardManager.clipboardController!))
    static let categorizationSettingsPage = SettingsTab("Categorization", Image(systemSymbol: .tray2), LuminareCategorizationSettings())
    static let aboutSettingsPage = SettingsTab("About", Image(systemSymbol: .infoBubble), LuminareAboutSettings())
    
    static var luminare: LuminareSettingsWindow?
    
    static func open() {
        print("open")
        if luminare == nil {
            shared.appExcluding = SettingsTab(
                "App Excluding",
                Image(systemSymbol: .xmarkSeal),
                LuminareExcludedAppsSettings().environmentObject(InstalledApps())
            )
            
            luminare = LuminareSettingsWindow(
                [
                    .init("App Settings", [
                        generalSettingsPage,
                        customizationSettingsPage
                    ]),
                    .init("Clipboard Settings", [
                        clipboardSettingsPage,
                        categorizationSettingsPage,
                        shared.appExcluding
                    ]),
                    .init("\(Bundle.main.appName)", [
                        aboutSettingsPage
                    ]),
                ],
                tint: {
                    Color.getAccent()
                },
                didTabChange: { _ in },
                showPreviewIcon: Image(nsImage: NSImage(size: .zero)),
                hidePreviewIcon: Image(nsImage: NSImage(size: .zero))
            )
            
        }
        luminare?.show()
        AppDelegate.isActive = true
        NSApp.setActivationPolicy(.regular)
    }
    
    static func fullyClose() {
        luminare?.close()
        luminare = nil
        NSApp.setActivationPolicy(.accessory)
    }
}
