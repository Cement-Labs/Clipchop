//
//  ClipHistoryViewController.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/17.
//

import SwiftUI
import Defaults
import KeyboardShortcuts

@Observable class ClipHistoryViewController {
    enum ExpansionState: Int, CaseIterable {
        case collapsing = 0x00
        case collapsed = 0x01
        
        case expanding = 0x10
        case expanded = 0x11
        
        var next: Self {
            switch self {
            case .collapsing: .collapsed
            case .collapsed: .expanding
            case .expanding: .expanded
            case .expanded: .collapsing
            }
        }
        
        var previous: Self {
            switch self {
            case .collapsing: .expanded
            case .collapsed: .collapsing
            case .expanding: .collapsed
            case .expanded: .expanding
            }
        }
        
        var intermediate: Self {
            switch self {
            case .collapsing, .collapsed: .collapsing
            case .expanding, .expanded: .collapsed
            }
        }
        
        var stable: Self {
            switch self {
            case .collapsing, .collapsed: .collapsed
            case .expanding, .expanded: .expanded
            }
        }
        
        var isStable: Bool {
            switch self {
            case .collapsing, .expanding: false
            case .collapsed, .expanded: true
            }
        }
        
        var isExpanding: Bool {
            self == .expanding || self == .expanded
        }
        
        var isExpanded: Bool {
            self == .expanded
        }
        
        var isCollapsing: Bool {
            self == .collapsing || self == .collapsed
        }
        
        var isCollapsed: Bool {
            self == .collapsed
        }
    }
    
    static let size = (
        collapsed: NSSize(width: 500, height: 85),
        expanded: NSSize(width: 500, height: 360)
    )
    
    private var windowController: NSWindowController?
    private var expansionStack: [Bool] = []
    
    private var state: ExpansionState = .collapsed
    
    var expansionState: ExpansionState {
        get {
            state
        }
    }
    
    init() {
        initObservations()
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
    
    func expansionEdge(position topLeft: CGPoint, maxSize size: CGSize) -> NSDirectionalRectEdge {
        guard let screenRect = NSScreen.main?.frame else { return .bottom }
        let bottomRight = topLeft.applying(.init(translationX: size.width, y: -size.height))
        
        if !screenRect.contains(bottomRight) {
            // Expands to the top
            return .top
        } else {
            // Expands to the bottom
            return .bottom
        }
    }
}

extension ClipHistoryViewController {
    // MARK: - Observations
    
    func initObservations() {
        Task { @MainActor in
            for await stack in observationTrackingStream({ self.expansionStack }) {
                print(self.expansionStack, stack)
            }
        }
    }
}

extension ClipHistoryViewController {
    // MARK: - Shortcuts
    
    func initShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .escape, action: self.close)
        KeyboardShortcuts.onKeyUp(for: .settings, action: NSApp.openSettings)
        KeyboardShortcuts.onKeyUp(for: .expand, action: self.expand)
        KeyboardShortcuts.onKeyUp(for: .collapse, action: self.collapse)
    }
    
    func enableShortcuts() {
        KeyboardShortcuts.enable(.escape)
        KeyboardShortcuts.enable(.settings)
        KeyboardShortcuts.enable(.expand)
        KeyboardShortcuts.enable(.collapse)
    }
    
    func disableShortcuts() {
        KeyboardShortcuts.disable(.escape)
        KeyboardShortcuts.disable(.settings)
        KeyboardShortcuts.disable(.expand)
        KeyboardShortcuts.disable(.collapse)
    }
}

extension ClipHistoryViewController {
    // MARK: - Animations
    
    func animateWindowSize(isExpanded: Bool) {
        guard let window = windowController?.window else { return }
        let frame = window.frame
        let targetSize = isExpanded ? Self.size.expanded : Self.size.collapsed
        let edge = expansionEdge(position: frame.origin, maxSize: Self.size.expanded)
        
        switch edge {
        case .top:
            // Expands/Shrinks the top edge
            window.setFrame(
                .init(origin: frame.origin, size: targetSize),
                display: true, animate: true
            )
        case .bottom:
            // Expands/Shrinks the bottom edge
            window.setFrame(
                .init(
                    origin: .init(x: frame.origin.x, y: frame.origin.y + frame.size.height),
                    size: targetSize
                ),
                display: true,
                animate: true
            )
        default: break
        }
    }
}

extension ClipHistoryViewController {
    // MARK: - Open / Close
    
    var isOpened: Bool {
        windowController != nil
    }
    
    func open(position: CGPoint) {
        state = .collapsed
        
        if let windowController {
            windowController.window?.orderFrontRegardless()
            return
        }
        
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
        panel.isMovableByWindowBackground = true
        
        panel.contentView = NSHostingView(
            rootView: ClipHistoryView()
        )
        panel.setFrame(
            CGRect(
                origin: positionNear(position: position, size: Self.size.collapsed)
                    .applying(.init(translationX: 0, y: -Self.size.collapsed.height)),
                size: Self.size.collapsed
            ),
            display: false
        )
        panel.orderFrontRegardless()
        
        windowController = .init(window: panel)
        
        initShortcuts()
        enableShortcuts()
    }
    
    func close() {
        guard let windowController else { return }
        self.windowController = nil
        windowController.close()
        
        disableShortcuts()
    }
    
    func toggle(position: CGPoint) {
        if isOpened {
            close()
        } else {
            open(position: position)
        }
    }
}

extension ClipHistoryViewController {
    // MARK: - Expand / Collapse
    
    func expand() {
        if expansionStack.last != true {
            expansionStack.append(true)
        }
    }
    
    func collapse() {
        if expansionStack.last != false {
            expansionStack.append(false)
        }
    }
}
