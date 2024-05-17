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
    
    func open(position: CGPoint) {
        if let windowController {
            windowController.window?.orderFrontRegardless()
            return
        }
        
        let mouseX: CGFloat = position.x
        let mouseY: CGFloat = position.y
        
        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true,
            screen: NSApp.keyWindow?.screen
        )
        
        panel.collectionBehavior = .canJoinAllSpaces
        panel.hasShadow = false
        panel.backgroundColor = .clear
        panel.level = .screenSaver
        panel.contentView = NSHostingView(
            rootView: ClipHistoryView()
        )
        panel.alphaValue = 0
        panel.setFrame(
            CGRect(
                x: mouseX,
                y: mouseY,
                width: 500,
                height: 75
            ),
            display: false
        )
        panel.orderFrontRegardless()
        
        windowController = .init(window: panel)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            panel.animator().alphaValue = 1
        }
    }
    
    func close() {
        guard let windowController else { return }
        self.windowController = nil
        
        windowController.window?.animator().alphaValue = 1
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            windowController.window?.animator().alphaValue = 0
        }, completionHandler: {
            windowController.close()
        })
    }
}
