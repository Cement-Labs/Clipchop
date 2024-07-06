//
//  KeyboardShortcutsSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/13.
//

import SwiftUI
import KeyboardShortcuts

struct KeyboardShortcutsSection: View {
    @Environment(\.hasTitle) private var hasTitle
    
    var body: some View {
        Section {
            KeyboardShortcuts.Recorder(for: .window) {
                withCaption {
                    Text("Show \(Bundle.main.appName)")
                } caption: {
                    Text("Call up the clip history window.")
                }
            }
        } header: {
            if hasTitle {
                Text("Keyboard Shortcuts")
            }
        }
        
        Section {
            KeyboardShortcuts.Recorder(for: .start) {
                withCaption {
                    Text("Clipboard monitoring")
                } caption: {
                    Text("Toggle clipboard history monitoring.")
                }
            }
        }
    }
}

#Preview {
    previewSection {
        KeyboardShortcutsSection()
    }
}
