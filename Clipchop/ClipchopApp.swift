//
//  ClipchopApp.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import SwiftUI
import Defaults
import KeyboardShortcuts
<<<<<<< HEAD
import SwiftData
=======
import MenuBarExtraAccess
>>>>>>> origin/rewrite/main

let onStreamTime = try! Date("2024-05-13T00:00:00Z", strategy: .iso8601)

@main
struct ClipchopApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
<<<<<<< HEAD
    
    @State private var isMenuBarPresented: Bool = true
    
    @Environment(\.modelContext) private var modelContext
    
    @Default(.menuBarItemEnabled) private var menuBarItemEnabled
    
    private let container: ModelContainer
    private let manager: ModelManager
    
    init() {
        self.container = try! .init(for: ClipboardContent.self, ClipboardHistory.self)
        self.manager = .init(context: container.mainContext)
=======
    
    @State var isMenuBarPresented: Bool = true
    
    @Default(.menuBarItemEnabled) private var menuBarItemEnabled
    
    private let clipboardModelEditor = ClipboardModelEditor(provider: .shared)
    private let clipHistoryViewController = ClipHistoryPanelController()
    private let clipboardManager: ClipboardManager
    
    init() {
        
        self.clipboardManager = .init(context: ClipboardDataProvider.shared.viewContext)
>>>>>>> origin/rewrite/main
        
#if DEBUG
        // Resets Defaults
        Defaults[.menuBarItemEnabled] = Defaults.Keys.menuBarItemEnabled.defaultValue
        Defaults[.beginningViewShown] = Defaults.Keys.beginningViewShown.defaultValue
        
<<<<<<< HEAD
        Defaults[.timesClipped] = Defaults.Keys.timesClipped.defaultValue
        Defaults[.clipSound] = Defaults.Keys.clipSound.defaultValue
        Defaults[.pasteSound] = Defaults.Keys.pasteSound.defaultValue
        
        Defaults[.categories] = Defaults.Keys.categories.defaultValue
        Defaults[.allTypes] = Defaults.Keys.allTypes.defaultValue
        
        Defaults[.excludeAppsEnabled] = Defaults.Keys.excludeAppsEnabled.defaultValue
        Defaults[.excludedApplications] = Defaults.Keys.excludedApplications.defaultValue
        
        Defaults[.historyPreservationPeriod] = Defaults.Keys.historyPreservationPeriod.defaultValue
        Defaults[.historyPreservationTime] = Defaults.Keys.historyPreservationTime.defaultValue
        
        // Resets clipboard history
        container.mainContext.autosaveEnabled = true
        try! container.mainContext.delete(model: ClipboardContent.self)
        try! container.mainContext.delete(model: ClipboardHistory.self)
#endif
        
        if !Defaults[.beginningViewShown] {
            // Shows beginning view once
            manager.beginningViewController.open()
            Defaults[.beginningViewShown] = true
        } else {
            // Alerts for permissions
=======
//        Defaults[.timesClipped] = Defaults.Keys.timesClipped.defaultValue
//        Defaults[.clipSound] = Defaults.Keys.clipSound.defaultValue
//        Defaults[.pasteSound] = Defaults.Keys.pasteSound.defaultValue
        
//        Defaults[.categories] = Defaults.Keys.categories.defaultValue
//        Defaults[.allTypes] = Defaults.Keys.allTypes.defaultValue
        
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
>>>>>>> origin/rewrite/main
            PermissionsManager.requestAccess()
        }
    }
    
    var body: some Scene {
        
        Settings {
            SettingsView()
<<<<<<< HEAD
                .frame(minHeight: 400, idealHeight: 425)
        }
        
        MenuBarExtra("Clipchop", image: "Empty", isInserted: $menuBarItemEnabled) {
            MenuBarView()
                .modelContainer(for: ClipboardHistory.self, isUndoEnabled: true)
                .modelContainer(for: ClipboardContent.self, isUndoEnabled: true)
=======
                .frame(minHeight: 200, idealHeight: 425)
        }
        
        MenuBarExtra("Clipchop", image: "Empty", isInserted: $menuBarItemEnabled) {
            MenuBarView(clipboardController: ClipboardManager.clipboardController!)
                .environment(\.managedObjectContext, ClipboardDataProvider.shared.viewContext)
>>>>>>> origin/rewrite/main
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
