//
//  ClipboardModelManager.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import AppKit
import Defaults
import KeyboardShortcuts

class ClipboardManager {
    static var clipboardController: ClipboardController?
    
    private let context: NSManagedObjectContext
    
    let beginningViewController = BeginningViewController()
    let clipHistoryViewController = ClipHistoryPanelController()
    let clipboardModelManager = ClipboardModelManager()
    
    init(context: NSManagedObjectContext) {
        
        self.context = context
        
        Self.clipboardController = .init(
            context: context,
            clipHistoryViewController: clipHistoryViewController,
            clipboardModelManager: clipboardModelManager
        )
        Self.clipboardController?.start()
        
        KeyboardShortcuts.onKeyDown(for: .window) {
            if Defaults[.cursorPosition] != .mouseLocation {
                if let screenCursorPosition = getIMECursorPosition() {
                    let globalCursorPosition = convertScreenToGlobalCoordinates(screenPoint: screenCursorPosition)
                    let adjustedPosition = CGPoint(x: globalCursorPosition.x - 20, y: globalCursorPosition.y - 28)
                    self.clipHistoryViewController.toggle(position: adjustedPosition)
                } else {
                    self.clipHistoryViewController.toggle(position: NSEvent.mouseLocation)
                }
            } else {
                self.clipHistoryViewController.toggle(position: NSEvent.mouseLocation)
            }
        }
        
        KeyboardShortcuts.onKeyDown(for: .start) {
            Self.clipboardController?.toggle()
        }
    }
}
