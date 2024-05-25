//
//  BeginningViewController.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI
import Defaults
import KeyboardShortcuts

@Observable class BeginningViewController {
    static let size = NSSize(width: 450, height: 500)
    
    private var windowController: NSWindowController?

    // MARK: - Open / Close
    
    var isOpened: Bool {
        windowController != nil
    }
    
    func open() {
        if let windowController {
            windowController.window?.orderFrontRegardless()
            return
        }
        
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.closable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        
        let screenRect = NSScreen.main?.frame ?? .null
        
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.collectionBehavior = .canJoinAllSpaces
        window.level = .normal
        window.isMovableByWindowBackground = true
        
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        window.contentView = NSHostingView(
            rootView: BeginningView()
        )
        window.setFrame(CGRect(
            x: screenRect.midX - Self.size.width / 2, y: screenRect.midY - Self.size.height / 2,
            width: Self.size.width, height: Self.size.height
        ), display: false)
        window.orderFrontRegardless()
        
        windowController = .init(window: window)
    }
    
    func close() {
        guard let windowController else { return }
        self.windowController = nil
        windowController.close()
    }
    
    func toggle() {
        if isOpened {
            close()
        } else {
            open()
        }
    }
}
