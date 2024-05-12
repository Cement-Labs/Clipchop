//
//  ClipchopApp.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/8.
//

import SwiftUI
import MenuBarExtraAccess
import Defaults

func quit() {
    NSApp.terminate(nil)
}

@main
struct ClipchopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var isMenuBarPresented: Bool = true
    
    @Default(.menuBarItemEnabled) var menuBarItemEnabled
    
#if DEBUG
    init() {
        // Reset menu bar item visibility
        Defaults[.menuBarItemEnabled] = true
    }
#endif
    
    var body: some Scene {
        Settings {
            SettingsView()
                .task {
                    if let window = NSApp.windows.last {
                        window.toolbarStyle = .unified
                    }
                }
                .frame(idealWidth: 680, minHeight: 350, idealHeight: 400, maxHeight: .infinity)
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
