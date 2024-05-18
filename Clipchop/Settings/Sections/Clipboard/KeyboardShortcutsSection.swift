//
//  KeyboardShortcutsSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/13.
//

import SwiftUI
import KeyboardShortcuts

struct KeyboardShortcutsSection: View {
    var body: some View {
        Section("Keyboard Shortcuts") {
            KeyboardShortcuts.Recorder(for: .window) {
                withCaption {
                    Text("Show \(Bundle.main.appName)")
                } caption: {
                    Text("The global keyboard shortcut for calling up the clip history window.")
                }
            }
        }
        
        Section {
            KeyboardShortcuts.Recorder(for: .pin) {
                Text("Pin history")
            }
            
            KeyboardShortcuts.Recorder(for: .delete) {
                Text("Delete history")
            }
        }
    }
}

#Preview {
    previewSection {
        KeyboardShortcutsSection()
    }
}
