//
//  MenuBarView.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import SwiftData
import Defaults

struct MenuBarView: View {
    @Default(.timesClipped) var timesClipped
    
    @Query(
        sort: \ClipboardHistory.time,
        order: .reverse
    ) private var items: [ClipboardHistory]
    
    @Environment(\.modelContext) var context
    
    var body: some View {
        
        let startIndex = 1
        
        Text("\(timesClipped) Clips, \(items.count) Items")
        
        if !items.isEmpty {
            Menu("Recent Clips") {
                ForEach(Array(items.prefix(9).enumerated()), id: \.element) { index, item in
                    Button {
                        let clipboardMonitor = ClipboardMonitor(context: context)
                        clipboardMonitor.copy(item)
                    } label: {
                        Text(item.formatter.title ?? "")
                    }
                    .keyboardShortcut(.init(String(index + startIndex).first!), modifiers: .option)
                }
            }
            .keyboardShortcut("r", modifiers: .option)
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
