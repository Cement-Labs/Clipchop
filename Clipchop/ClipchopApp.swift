//
//  ClipchopApp.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/8.
//

import SwiftUI
import MenuBarExtraAccess

@main
struct ClipchopApp: App {
    @State var isMenuBarItemInserted: Bool = true
    
    var body: some Scene {
        Settings {
            SettingsView()
                .task {
                    if let window = NSApp.windows.last {
                        window.toolbarStyle = .unified
                    }
                }
                .frame(minHeight: 400)
                .fixedSize(horizontal: true, vertical: false)
        }
        
        MenuBarExtra("Clipchop", image: "Empty", isInserted: .constant(true)) {
            SettingsLink {
                Text("Settings…")
            }
            .keyboardShortcut(",", modifiers: .command)
        }
        .menuBarExtraStyle(.menu)
        .menuBarExtraAccess(isPresented: $isMenuBarItemInserted) { menuBarItem in
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
