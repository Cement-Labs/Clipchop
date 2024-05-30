//
//  KeyboardShortcutsSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/13.
//

import SwiftUI
import KeyboardShortcuts

struct KeyboardShortcutsSection: View {
    @Environment(\.hasTitle) var hasTitle
    
    var body: some View {
        Section {
            KeyboardShortcuts.Recorder(for: .window) {
                withCaption {
                    Text("Show \(Bundle.main.appName)")
                } caption: {
                    Text("The global keyboard shortcut for calling up the clip history window.")
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
                    Text("Clipboard History Recording")
                } caption: {
                    Text("Enable or disable clipboard history recording.")
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
