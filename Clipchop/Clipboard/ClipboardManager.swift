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
            let cursorPosition = Defaults[.cursorPosition]
            
            let position: CGPoint
            
            switch cursorPosition {
            case .mouseLocation:
                position = NSEvent.mouseLocation
                
            case .adjustedPosition:
                if let screenCursorPosition = getIMECursorPosition() {
                    let globalCursorPosition = convertScreenToGlobalCoordinates(screenPoint: screenCursorPosition)
                    position = CGPoint(x: globalCursorPosition.x - 20, y: globalCursorPosition.y - 28)
                } else {
                    position = NSEvent.mouseLocation
                }
                
            case .fixedPosition:
                if let screen = NSScreen.main {
                    let screenFrame = screen.frame
                    
                    let x = screenFrame.midX - (Defaults[.displayMore] ? 350 : 250)
                    
                    let y = screenFrame.minY + (Defaults[.displayMore] ? 250 : 200)
                    
                    let fixedPosition = CGPoint(x: x, y: y)
                    
                    position = fixedPosition
                } else {
                    position = NSEvent.mouseLocation
                }
            }
            
            self.clipHistoryViewController.toggle(position: position)
        }
        
        KeyboardShortcuts.onKeyDown(for: .start) {
            Self.clipboardController?.toggle()
        }
    }
}
