//
//  ClipchopApp.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import SwiftUI
import Defaults
import KeyboardShortcuts
import MenuBarExtraAccess

let onStreamTime = try! Date("2024-05-13T00:00:00Z", strategy: .iso8601)

@main
struct ClipchopApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var isMenuBarPresented: Bool = true
    
    @Default(.menuBarItemEnabled) private var menuBarItemEnabled
    
    private let clipboardModelEditor = ClipboardModelEditor(provider: .shared)
    private let clipHistoryViewController = ClipHistoryPanelController()
    private let clipboardManager: ClipboardManager
    
    init() {
        
        self.clipboardManager = .init(context: ClipboardDataProvider.shared.viewContext)
        
#if DEBUG
        // Resets Defaults
        Defaults[.menuBarItemEnabled] = Defaults.Keys.menuBarItemEnabled.defaultValue
        Defaults[.beginningViewShown] = Defaults.Keys.beginningViewShown.defaultValue
        
//        Defaults[.timesClipped] = Defaults.Keys.timesClipped.defaultValue
//        Defaults[.clipSound] = Defaults.Keys.clipSound.defaultValue
//        Defaults[.pasteSound] = Defaults.Keys.pasteSound.defaultValue
        
        Defaults[.categories] = Defaults.Keys.categories.defaultValue
        Defaults[.allTypes] = Defaults.Keys.allTypes.defaultValue
        
//        Defaults[.excludeAppsEnabled] = Defaults.Keys.excludeAppsEnabled.defaultValue
//        Defaults[.excludedApplications] = Defaults.Keys.excludedApplications.defaultValue
        
//        Defaults[.historyPreservationPeriod] = Defaults.Keys.historyPreservationPeriod.defaultValue
//        Defaults[.historyPreservationTime] = Defaults.Keys.historyPreservationTime.defaultValue
        
        // Resets clipboard history
//        try? clipboardModelEditor.deleteAll()
#endif
        if !Defaults[.beginningViewShown] {
            clipboardManager.beginningViewController.open()
            Defaults[.beginningViewShown] = true
        } else {
            PermissionsManager.requestAccess()
        }
    }
    
    var body: some Scene {
        
        Settings {
            SettingsView()
                .frame(minHeight: 200, idealHeight: 425)
        }
        
        MenuBarExtra("Clipchop", image: "Empty", isInserted: $menuBarItemEnabled) {
            MenuBarView()
                .environment(\.managedObjectContext, ClipboardDataProvider.shared.viewContext)
        }
        .menuBarExtraStyle(.menu)
        .menuBarExtraAccess(isPresented: $isMenuBarPresented) { menuBarItem in
            guard
                // Init once
                let button = menuBarItem.button,
                button.subviews.count == 0
            else {
                return
            }
            
            menuBarItem.length = 24
            
            let view = NSHostingView(rootView: MenuBarIconView())
            view.frame.size = .init(width: 24, height: NSStatusBar.system.thickness)
            button.addSubview(view)
        }
    }
}
