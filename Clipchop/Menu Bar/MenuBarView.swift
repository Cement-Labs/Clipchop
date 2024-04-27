//
//  MenuBarView.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI

struct MenuBarView: View {
    var body: some View {
        Menu("Recent Copied") {
            Button("Example") {
                
            }
        }
        
        Divider()
        
        SettingsLink {
            Text("Settings…")
        }
        .keyboardShortcut(",", modifiers: .command)
        
        Button("Quit \(Bundle.main.appName)") {
            quit()
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
