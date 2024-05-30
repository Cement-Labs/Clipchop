//
//  ClipchopApp.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/8.
//

import SwiftUI
import MenuBarExtraAccess
import Defaults
import KeyboardShortcuts
import SwiftData

let onStreamTime = try! Date("2024-05-13T00:00:00Z", strategy: .iso8601)

@main
struct ClipchopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var isMenuBarPresented = true
    @State var isWindowInitialized = false
    
    @Default(.menuBarItemEnabled) var menuBarItemEnabled
    @Default(.preferredColorScheme) var preferredColorScheme
    
    private let container: ModelContainer
    private let manager: ModelManager
    
    init() {
        self.container = try! .init(for: ClipboardContent.self, ClipboardHistory.self)
        self.manager = .init(context: container.mainContext)
        
#if DEBUG
        
        // Resets Defaults
        Defaults[.menuBarItemEnabled] = Defaults.Keys.menuBarItemEnabled.defaultValue
        Defaults[.beginningViewShown] = Defaults.Keys.beginningViewShown.defaultValue
        
        Defaults[.timesClipped] = Defaults.Keys.timesClipped.defaultValue
        Defaults[.clipSound] = Defaults.Keys.clipSound.defaultValue
        Defaults[.pasteSound] = Defaults.Keys.pasteSound.defaultValue
        
        Defaults[.categories] = Defaults.Keys.categories.defaultValue
        Defaults[.allTypes] = Defaults.Keys.allTypes.defaultValue
        
        Defaults[.excludeAppsEnabled] = Defaults.Keys.excludeAppsEnabled.defaultValue
        Defaults[.applicationExcludeList] = Defaults.Keys.applicationExcludeList.defaultValue
        
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
            PermissionsManager.requestAccess()
        }
    }
    
    var body: some Scene {
        Settings {
            SettingsView(isWindowInitialized: $isWindowInitialized)
                .task {
                    if let window = NSApp.windows.last {
                        window.visibleWindowButtonTypes = []
                        window.titlebarAppearsTransparent = true
                        
                        // Delays a little bit
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            window.visibleWindowButtonTypes = [.closeButton, .miniaturizeButton, .zoomButton]
                            window.toolbarStyle = .automatic
                            window.titlebarAppearsTransparent = false
                            window.titlebarSeparatorStyle = .automatic
                            
                            withAnimation {
                                // Tells the navigation split view to appear
                                isWindowInitialized = true
                            }
                        }
                    }
                }
                .frame(minHeight: 400, idealHeight: 425, maxHeight: 450)
                .preferredColorScheme(preferredColorScheme.colorScheme)
        }
        
        MenuBarExtra("Clipchop", image: "Empty", isInserted: $menuBarItemEnabled) {
            MenuBarView()
                .modelContainer(for: ClipboardHistory.self, isUndoEnabled: true)
                .modelContainer(for: ClipboardContent.self, isUndoEnabled: true)
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
