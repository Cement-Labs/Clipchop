//
//  FloatingWindow.swift
//  ClipChop
//
//  Created by Xinshao_Air on 2024/5/31.
//

import SwiftUI
import AppKit
import KeyboardShortcuts

class FloatingPaneHleper: NSPanel {
    
    private var isExpanded = false
    private var expansionEdge: NSRectEdge = .minY
    private var isClosing = false
    
    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.resizable, .closable, .nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: true
        )
        
        collectionBehavior = .canJoinAllSpaces
        isFloatingPanel = true
        level = .floating
        
        backgroundColor = NSColor.clear
        hasShadow = true
        
        let clipHistoryView = ClipHistoryView()
            .modelContainer(for: ClipboardHistory.self, isUndoEnabled: true)
            .modelContainer(for: ClipboardContent.self, isUndoEnabled: true)
        
        contentView = NSHostingView(rootView: clipHistoryView)
        
        isMovableByWindowBackground = false
        
        animationBehavior = .utilityWindow
        
        initShortcuts()
    }
        
    override func resignMain() {
        super.resignMain()
        close()
    }
    
    override func resignKey() {
        super.resignKey()
        close()
    }
    
    override func close() {
        super.close()
        isClosing = false
        disableShortcuts()
        log(self, "Clipboard close")
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    // MARK: - Shortcuts
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            close()
        } else {
            super.keyDown(with: event)
        }
    }
    
    func initShortcuts() {
        KeyboardShortcuts.onKeyDown(for: .expand) {
            self.expand()
        }
        KeyboardShortcuts.onKeyDown(for: .collapse) {
            self.collapse()
        }
    }
    
    func enableShortcuts() {
        KeyboardShortcuts.enable(.expand)
        KeyboardShortcuts.enable(.collapse)
    }
    
    func disableShortcuts() {
        KeyboardShortcuts.disable(.expand)
        KeyboardShortcuts.disable(.collapse)
    }
    
    // MARK: - Expand / Collapse
    
    func expand() {
        setWindowSize(isExpanded: true)
    }
    
    func collapse() {
        setWindowSize(isExpanded: false)
    }
    
    func setWindowSize(isExpanded: Bool, animate: Bool = true) {
        guard self.isExpanded != isExpanded else { return }
        let frame = self.frame
        let targetSize = isExpanded ? CGSize(width: 500, height: 360) : CGSize(width: 500, height: 100)
        
        let edge: NSRectEdge
        if isExpanded {
            edge = expansionEdge(
                position: frame.origin.applying(.init(translationX: 0, y: 100)),
                size: targetSize
            )
            expansionEdge = edge
        } else {
            edge = expansionEdge
        }
        
        switch edge {
        case .maxY:
            self.setFrame(.init(origin: frame.origin, size: targetSize), display: true, animate: animate)
        case .minY:
            self.setFrame(.init(origin: .init(x: frame.origin.x, y: frame.origin.y + frame.size.height - targetSize.height), size: targetSize), display: true, animate: animate)
        default: break
        }
        
        self.isExpanded = isExpanded
    }
    
    // MARK: - Positioning
    
    func positionNear(position topLeft: CGPoint, size: CGSize) -> CGPoint {
        guard let screenRect = NSScreen.main?.frame else { return topLeft }
        let bottomRight = topLeft.applying(.init(translationX: size.width, y: -size.height))
        
        if !screenRect.contains(bottomRight) {
            if screenRect.maxX < bottomRight.x && screenRect.minY > bottomRight.y {
                return .init(x: screenRect.maxX - size.width, y: screenRect.minY + size.height)
            } else if screenRect.maxX < bottomRight.x {
                return .init(x: screenRect.maxX - size.width, y: topLeft.y)
            } else if screenRect.minY > bottomRight.y {
                return .init(x: topLeft.x, y: screenRect.minY + size.height)
            }
        } else {
            return topLeft
        }
        
        return topLeft
    }
    
    func expansionEdge(position topLeft: CGPoint, size: CGSize) -> NSRectEdge {
        guard let screenRect = NSScreen.main?.frame else { return expansionEdge }
        let bottomRight = topLeft.applying(.init(translationX: size.width, y: -size.height))
        
        if !screenRect.contains(bottomRight) {
            return .maxY
        } else {
            return .minY
        }
    }
    
    // MARK: - Open / Close
    
    func open(position: CGPoint) {
        isClosing = true
        setFrameOrigin(positionNear(position: position, size: CGSize(width: 500, height: 100))
            .applying(.init(translationX: 0, y: -100)))
        makeKeyAndOrderFront(nil)
        enableShortcuts()
    }
    
    func toggle(position: CGPoint) {
        if isVisible {
            close()
        } else {
            open(position: position)
        }
    }
    
    func pasteClose() {
        guard !isClosing else { return }
        isClosing = true
        makeMain()
        close()
    }
}
