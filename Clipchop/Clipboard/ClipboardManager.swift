//
//  ClipboardModelManager.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import AppKit
import KeyboardShortcuts

class ClipboardManager {
    static var clipboardController: ClipboardController?
    
    private let context: NSManagedObjectContext
    
    let beginningViewController = BeginningViewController()
    let clipHistoryViewController = ClipHistoryViewController()
    let clipboardModelManager = ClipboardModelManager()
    
    init(context: NSManagedObjectContext) {
        
        self.context = context
        
        Self.clipboardController = .init(context: context, clipHistoryViewController: clipHistoryViewController, clipboardModelManager: clipboardModelManager)
        Self.clipboardController?.start()
        
        KeyboardShortcuts.onKeyDown(for: .window) {
            self.clipHistoryViewController.toggle(position: NSEvent.mouseLocation)
        }
        
        KeyboardShortcuts.onKeyDown(for: .start) {
            Self.clipboardController?.toggle()
        }
    }
}
