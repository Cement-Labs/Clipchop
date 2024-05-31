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
    
    let monitor: ClipboardMonitor
    private var floatingPaneHelper: FloatingPaneHleper?
    
    init(context: ModelContext) {
        self.context = context
        self.monitor = .init(context: context)
        
        monitor.start()
        
        KeyboardShortcuts.onKeyDown(for: .window) { [self] in
            self.toggleFloatingPane()
        }
        KeyboardShortcuts.onKeyDown(for: .start) { [self] in
            self.monitor.toggle()
        }
    }
    
    private func toggleFloatingPane() {
        if floatingPaneHelper == nil {
            floatingPaneHelper = FloatingPaneHleper()
        }
        floatingPaneHelper?.toggle(position: NSEvent.mouseLocation)
    }
}
