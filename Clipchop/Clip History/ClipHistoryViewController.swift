//
//  ClipHistoryViewController.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/17.
//

import SwiftUI
import Defaults

class ClipHistoryViewController {
    private var windowController: NSWindowController?
    
    var isOpened: Bool {
        windowController != nil
    }
    
    func open(position: CGPoint) {
        if let windowController {
            windowController.window?.orderFrontRegardless()
            return
        }
        
        let size: CGSize = .init(width: 500, height: 75)
        
        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true,
            screen: NSApp.keyWindow?.screen
        )
        
        panel.animationBehavior = .utilityWindow
        panel.collectionBehavior = .canJoinAllSpaces
        panel.hasShadow = true
        panel.backgroundColor = .clear
        panel.level = .screenSaver
        panel.contentView = NSHostingView(
            rootView: ClipHistoryView()
        )
        panel.setFrame(
            CGRect(
                origin: positionNear(position: position,size: size)
                    .applying(.init(translationX: 0, y: -size.height)),
                size: size
            ),
            display: false
        )
        panel.orderFrontRegardless()
        
        windowController = .init(window: panel)
    }
    
    func close() {
        guard let windowController else { return }
        self.windowController = nil
        windowController.close()
    }
    
    func toggle(position: CGPoint) {
        if isOpened {
            close()
        } else {
            open(position: position)
        }
    }
    
    func positionNear(position topLeft: CGPoint, size: CGSize) -> CGPoint {
        guard let screenRect = NSScreen.main?.frame else { return topLeft }
        let bottomRight = topLeft.applying(.init(translationX: size.width, y: -size.height))
        
        if !screenRect.contains(bottomRight) {
            // Current position produces out of screen contents
            if screenRect.maxX < bottomRight.x && screenRect.minY > bottomRight.y {
                // Completely out of screen
                return .init(x: screenRect.maxX - size.width, y: screenRect.minY + size.height)
            } else if screenRect.maxX < bottomRight.x {
                // Only horizontally out of screen
                return .init(x: screenRect.maxX - size.width, y: topLeft.y)
            } else if screenRect.minY < bottomRight.y {
                // Only vertically out of screen
                return .init(x: topLeft.x, y: screenRect.minY + size.height)
            }
        } else {
            // All set
            return topLeft
        }
        
        // Well...
        return topLeft
    }
    
    func expandDirection(position: CGPoint, size: CGSize) -> NSDirectionalRectEdge {
        guard let screenRect = NSScreen.main?.frame else { return .bottom }
        let bottomRight = position.applying(.init(translationX: size.width, y: -size.height))
        
        if !screenRect.contains(bottomRight) {
            // Expands to the top
            return .top
        } else {
            // Expands to the bottom
            return .bottom
        }
    }
}
