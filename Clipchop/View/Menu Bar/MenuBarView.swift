//
//  MenuBarView.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import Defaults

struct MenuBarView: View {
    
    @FetchRequest(fetchRequest: ClipboardHistory.all()) private var items
    
    @ObservedObject var clipboardController: ClipboardController
    
    @Default(.dnd) private var dnd
    
    var body: some View {
        Text("\(Defaults[.timesClipped]) Clips, \(items.count) Items")
        
        if !items.isEmpty {
            Menu("Recent Clips") {
                ForEach(Array(items.prefix(9).enumerated()), id: \.element) { index, item in
                    Button {
                        ClipboardManager.clipboardController?.copy(item)
                    } label: {
                        Text(item.formatter.title ?? "")
                    }
                    .keyboardShortcut(.init(String(index + 1).first!), modifiers: .command)
                }
            }
            .keyboardShortcut("r", modifiers: .option)
        }
        
        Divider()
        
        Toggle("Clipboard Monitoring", isOn: $clipboardController.started)
        
        Toggle("Do Not Disturb", isOn: $dnd)
        
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
