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

func quit() {
    NSApp.terminate(nil)
}

// https://stackoverflow.com/questions/29847611/restarting-osx-app-programmatically
func relaunch() {
    let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
    let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
    let task = Process()
    
    task.launchPath = "/usr/bin/open"
    task.arguments = [path]
    task.launch()
    
    quit()
}

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
        // Resets UI states
        Defaults[.menuBarItemEnabled] = true
        Defaults[.beginningViewShown] = false
        
        // Resets user interactions
        Defaults[.timesClipped] = 0
        Defaults[.clipSound] = Sound.defaultSound
        
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
                        // Delays a little bit
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            window.toolbarStyle = .automatic
                            window.titlebarSeparatorStyle = .automatic
                            
                            withAnimation {
                                // Tells the navigation split view to appear
                                isWindowInitialized = true
                            }
                        }
                    }
                }
                .frame(minHeight: 400)
                .preferredColorScheme(preferredColorScheme.colorScheme)
        }
        
        MenuBarExtra("Clipchop", image: "Empty", isInserted: $menuBarItemEnabled) {
            MenuBarView()
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
