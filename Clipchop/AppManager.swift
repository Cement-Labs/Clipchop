//
//  ClipchopModel.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/17.
//

import KeyboardShortcuts
import AppKit

struct AppManager {
    let monitor = ClipboardMonitor(context: ClipboardDataProvider.shared.viewContext)
    let editModel = ClipboardEditModel(provider: .shared)
    
    let clipHistoryViewController = ClipHistoryViewController()
    
    init() {
        monitor.start()
        
        KeyboardShortcuts.onKeyUp(for: .window) { [self] in
            clipHistoryViewController.toggle(position: NSEvent.mouseLocation)
        }
    }
}
