//
//  ModelManager.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/17.
//

import KeyboardShortcuts
import AppKit
import SwiftData

class ModelManager {
    private let context: ModelContext
    private let monitor: ClipboardMonitor
    
    init(context: ModelContext) {
        self.context = context
        self.monitor = .init(context: context)
        
        monitor.start()
        
        KeyboardShortcuts.onKeyDown(for: .window) { [self] in
            self.toggle()
        }
        
        KeyboardShortcuts.onKeyDown(for: .start) { [self] in
            self.monitor.toggle()
        }
    }
    
    func toggle() {
        ClipHistoryPanel.shared.toggle(position: NSEvent.mouseLocation)
    }
}
