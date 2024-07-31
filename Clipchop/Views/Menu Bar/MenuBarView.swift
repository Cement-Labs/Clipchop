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
    
    @Default(.copyShortcut) var copyShortcut
    
    var body: some View {
        Text("\(Defaults[.timesClipped]) Clips, \(items.count) Items")
        
        if !items.isEmpty {
            Menu("Recent Clips") {
                ForEach(Array(items.prefix(9).enumerated()), id: \.element) { index, item in
                    Button {
                        ClipboardManager.clipboardController?.copy(item)
                    } label: {
                        Group {
                            if let title = item.formatter.title {
                                let fileExtensions = title.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                                let categorizedTitle = categorizeFileExtensions(fileExtensions)
                                Text(categorizedTitle)
                            } else {
                                Text("Other")
                            }
                        }
                    }
                    .keyboardShortcut(.init(String(index + 1).first!), modifiers: copyShortcut.eventModifier)
                }
            }
            .keyboardShortcut("r", modifiers: .option)
        }
        
        Divider()
        
        Toggle("Clipboard Monitoring", isOn: $clipboardController.started)
        
        Toggle("Do Not Disturb", isOn: $dnd)
        
        Divider()
        
        Button("Settings…") {
            LuminareManager.open()
        }
        .keyboardShortcut(",", modifiers: .command)
        
        Button("Quit \(Bundle.main.appName)") {
            quit()
        }
        .keyboardShortcut("q", modifiers: .command)
    }
    
    func categorizeFileExtensions(_ fileExtensions: [String]) -> String {
        let categories = Defaults[.categories]
        for fileExtension in fileExtensions {
            if let category = categories.first(where: { $0.types.contains(fileExtension) }) {
                return category.name
            }
        }
        return fileExtensions.joined(separator: ", ")
    }
}
