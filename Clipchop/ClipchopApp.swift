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

let onStreamTime = try! Date("2024-05-13T00:00:00Z", strategy: .iso8601)

func quit() {
    NSApp.terminate(nil)
}

@main
struct ClipchopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var isMenuBarPresented: Bool = true
    @State var isWindowInitialized: Bool = false
    
    @Default(.menuBarItemEnabled) var menuBarItemEnabled
    
    let monitor = ClipboardMonitor(context: ClipboardDataProvider.shared.viewContext)
    let editModel = ClipboardEditModel(provider: .shared)
    
    init() {
        monitor.start()
        
#if DEBUG
        // Resets menu bar item visibility
        Defaults[.menuBarItemEnabled] = true
        
        // Resets user interactions
        Defaults[.timesClipped] = 0
        Defaults[.sound] = Sound.defaultSound
        
        // Resets clipboard history
        try! editModel.deleteAll()
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
                            
                            withAnimation {
                                // Tells the navigation split view to appear
                                isWindowInitialized = true
                            }
                        }
                    }
                }
                .frame(minHeight: 300)
        }
        
        WindowGroup(id: SceneID.clipHistoryWindow.id) {
            ClipHistoryView()
        }
        .enableOpenWindow()
        
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
