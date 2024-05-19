//
//  ClipchopApp.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/8.
//

import SwiftUI
import MenuBarExtraAccess
import Defaults
import WindowManagement
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
    @State var isMenuBarPresented: Bool = true
    @State var isWindowInitialized: Bool = false
    
    @Default(.menuBarItemEnabled) var menuBarItemEnabled
    @Default(.preferredColorScheme) var preferredColorScheme
    
    @Environment(\.colorScheme) var colorScheme
    
    private let container: ModelContainer
    private let manager: ModelManager
    
    init() {
        self.container = try! .init(for: ClipboardContent.self, ClipboardHistory.self)
        self.manager = .init(context: container.mainContext)
        
#if DEBUG
        // Resets menu bar item visibility
        Defaults[.menuBarItemEnabled] = true
        
        // Resets user interactions
        Defaults[.timesClipped] = 0
        Defaults[.clipSound] = Sound.defaultSound
        
        // Resets clipboard history
        container.mainContext.autosaveEnabled = true
        try! container.mainContext.delete(model: ClipboardContent.self)
        try! container.mainContext.delete(model: ClipboardHistory.self)
#endif
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
                .tint(Defaults.accentColor)
                .frame(minHeight: 300)
                .preferredColorScheme(preferredColorScheme.colorScheme ?? colorScheme)
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
