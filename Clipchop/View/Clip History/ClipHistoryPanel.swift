//
//  ClipHistoryPanel.swift
//  ClipChop
//
//  Created by Xinshao_Air on 2024/5/31.
//

import SwiftUI
import AppKit
import KeyboardShortcuts

class ClipHistoryPanel: NSPanel {
    
    private let controller: ClipHistoryPanelController
    
    init(_ controller: ClipHistoryPanelController) {
        self.controller = controller
        super.init(
            contentRect: .zero,
            styleMask: [.nonactivatingPanel, .borderless, .closable],
            backing: .buffered,
            defer: true
        )
        
        animationBehavior = .utilityWindow
        collectionBehavior = .canJoinAllSpaces
        isFloatingPanel = true
        isMovableByWindowBackground = false
        level = .floating
        
        backgroundColor = NSColor.clear
        hasShadow = true
        
        let clipHistoryView = ClipHistoryView()
            .environment(\.managedObjectContext, ClipboardDataProvider.shared.viewContext)
        
        contentViewController = controller
        contentView = NSHostingView(rootView: clipHistoryView)
    }
    
    override func resignMain() {
        super.resignMain()
        close()
    }
    
    override func close() {
        controller.close()
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    // MARK: - Shortcuts
    
    override func keyDown(with event: NSEvent) {
        switch KeyboardShortcuts.Shortcut(event: event) {
        case KeyboardShortcuts.Key.escape.shortcut:
            close()
        case KeyboardShortcuts.Name.expand.shortcut:
            controller.expand()
        case KeyboardShortcuts.Name.collapse.shortcut:
            controller.collapse()
        default:
            super.keyDown(with: event)
        }
    }
}
