//
//  ModelManager.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/17.
//

import KeyboardShortcuts
import AppKit
import SwiftData

struct ModelManager {
    let context: ModelContext
    
    let monitor: ClipboardMonitor
    let clipHistoryViewController = ClipHistoryViewController()
    let beginningViewController = BeginningViewController()
    
    init(context: ModelContext) {
        self.context = context
        self.monitor = .init(context: context)
        
        monitor.start()
        
        KeyboardShortcuts.onKeyDown(for: .window) { [self] in
            clipHistoryViewController.toggle(position: NSEvent.mouseLocation)
        }
    }
}
