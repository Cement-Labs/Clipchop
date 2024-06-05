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
    static var monitor: ClipboardMonitor?
    
    private let context: ModelContext
    
    let beginningViewController = BeginningViewController()
    let clipHistoryViewController = ClipHistoryViewController()
    let clipboardManager = ClipboardManager()
    
    init(context: ModelContext) {
        self.context = context
        
        Self.monitor = .init(context: context, controller: clipHistoryViewController, clipboardManager: clipboardManager)
        Self.monitor?.start()
        
        KeyboardShortcuts.onKeyDown(for: .window) {
            self.clipHistoryViewController.toggle(position: NSEvent.mouseLocation)
        }
        
        KeyboardShortcuts.onKeyDown(for: .start) {
            Self.monitor?.toggle()
        }
    }
}
