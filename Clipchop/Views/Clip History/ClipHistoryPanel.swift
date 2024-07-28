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
        isMovable = true
        level = .popUpMenu
        
        backgroundColor = NSColor.clear
        hasShadow = true
        
        let clipHistoryView = ClipHistoryView(controller: controller)
            .environment(\.managedObjectContext, ClipboardDataProvider.shared.viewContext)
        
        let hostingView = NSHostingView(rootView: clipHistoryView)
        
        let backgroundView = DraggableBackgroundView(frame: self.frame)
        backgroundView.autoresizingMask = [.width, .height]
        
        self.contentView?.addSubview(backgroundView)
        self.contentView?.addSubview(hostingView)
        
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: self.contentView!.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: self.contentView!.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: self.contentView!.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: self.contentView!.bottomAnchor)
        ])
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
    
    override func mouseDown(with event: NSEvent) {
        controller.resetCloseTimer()
        super.mouseDown(with: event)
    }
    
    override func mouseMoved(with event: NSEvent) {
        controller.resetCloseTimer()
        super.mouseMoved(with: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        controller.resetCloseTimer()
        super.scrollWheel(with: event)
    }
    
    // MARK: - Shortcuts
    
    override func keyDown(with event: NSEvent) {
        switch KeyboardShortcuts.Shortcut(event: event) {
        case KeyboardShortcuts.Name.settings.shortcut:
            LuminareManager.open()
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

class DraggableBackgroundView: NSView {
    override func mouseDown(with event: NSEvent) {
        self.window?.performDrag(with: event)
    }
}
