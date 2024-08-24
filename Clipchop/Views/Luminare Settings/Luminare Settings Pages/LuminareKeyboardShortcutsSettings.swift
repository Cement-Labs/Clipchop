//
//  LuminareKeyboardShortcutsSettings.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/28.
//

import SwiftUI
import Luminare
import Defaults
import KeyboardShortcuts

struct LuminareKeyboardShortcutsSettings: View {
    @Default(.deleteShortcut) private var deleteShortcut
    @Default(.copyShortcut) private var copyShortcut
    @Default(.pinShortcut) private var pinShortcut
    @Default(.keySwitcher) private var keySwitcher
    
    var body: some View {
        LuminareSection("Keyboard Shortcuts") {
            HStack {
                withCaption {
                    Text("Show \(Bundle.main.appName)")
                } caption: {
                    Text("Call up the clip history window.")
                }
                Spacer()
                
                KeyboardShortcuts.Recorder(for: .window) { }
                    .controlSize(.large)
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 42)
            
            HStack {
                withCaption {
                    Text("Clipboard Monitoring")
                } caption: {
                    Text("Enable or disable monitoring of your clipboard history.")
                }
                Spacer()
                
                KeyboardShortcuts.Recorder(for: .start) { }
                    .controlSize(.large)
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 42)
        }
        LuminareSection {
            HStack {
                withCaption {
                    Text("Quick Selection")
                } caption: {
                    Text("This option only adjusts quickly selected trigger keys, toggle selected using Tab and ` ")
                }
                Spacer()
                CustomLuminarePicker(
                    selection: $keySwitcher,
                    items: KeyboardSwitcher.allCases
                ) { modifier in
                    modifier.switcherDisplayName
                }
                .frame(alignment: .trailing)
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 58)
        }
        
        LuminareSection {
            HStack {
                Text("Copy Shortcut")
                Spacer()
                CustomLuminarePicker(
                    selection: $copyShortcut,
                    items: KeyboardModifier.allCases
                ) { modifier in
                    modifier.displayName
                }
                .frame(alignment: .trailing)
                .onChange(of: copyShortcut) { _, _ in
                    ensureUniqueModifiers(changingKey: .copyShortcut)
                }
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 34)
            
            HStack {
                Text("Pin Shortcut")
                Spacer()
                CustomLuminarePicker(
                    selection: $pinShortcut,
                    items: KeyboardModifier.allCases
                ) { modifier in
                    modifier.displayName
                }
                .frame(alignment: .trailing)
                .onChange(of: pinShortcut) { _, _ in
                    ensureUniqueModifiers(changingKey: .pinShortcut)
                }
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 34)
            
            HStack {
                Text("Delete Shortcut")
                Spacer()
                CustomLuminarePicker(
                    selection: $deleteShortcut,
                    items: KeyboardModifier.allCases
                ) { modifier in
                    modifier.displayName
                }
                .frame(alignment: .trailing)
                .onChange(of: deleteShortcut) { _, _ in
                    ensureUniqueModifiers(changingKey: .deleteShortcut)
                }
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 34)
        }
    }
    
    private func ensureUniqueModifiers(changingKey: Defaults.Key<KeyboardModifier>) {
        var usedModifiers: Set<KeyboardModifier> = []
        let shortcuts: [Defaults.Key<KeyboardModifier>] = [.deleteShortcut, .copyShortcut, .pinShortcut]
        
        for shortcut in shortcuts {
            if shortcut == changingKey {
                // Skip the current key to ensure it is set successfully
                continue
            }
            if Defaults[shortcut] == Defaults[changingKey] {
                // If another shortcut has the same modifier, set it to none
                Defaults[shortcut] = .none
            }
            usedModifiers.insert(Defaults[shortcut])
        }
    }
}
