//
//  ClipHistoryViewController.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/17.
//

import SwiftUI
import SwiftData
import Defaults
import KeyboardShortcuts

class FloatingPaneHleper<Content: View>: NSPanel {
    
    init(position: CGPoint, show: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        
        super.init(contentRect: .zero, styleMask: [.resizable, .closable, .fullSizeContentView, .nonactivatingPanel], backing: .buffered, defer: false)
        
        animationBehavior = .utilityWindow
        collectionBehavior = .canJoinAllSpaces
        hasShadow = true
        backgroundColor = .white.withAlphaComponent(0.000001)
        level = .floating
        isMovableByWindowBackground = false
        
        let clipHistoryView = content()
        
        contentView = NSHostingView(rootView: clipHistoryView)
        
        setFrameOrigin(position)
        
    }
}

@Observable class ClipHistoryViewController: ViewController {
    static let size = (
        collapsed: NSSize(width: 500, height: 100),
        expanded: NSSize(width: 500, height: 360)
    )
    
    private var windowController: NSWindowController?
    private var isExpanded = false
    private var expansionEdge: NSRectEdge = .minY
    
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
}

extension ClipHistoryViewController {
    // MARK: - Shortcuts
    
    func initShortcuts() {
        KeyboardShortcuts.onKeyDown(for: .escape, action: self.close)
        KeyboardShortcuts.onKeyDown(for: .settings, action: NSApp.openSettings)
        KeyboardShortcuts.onKeyDown(for: .expand, action: self.expand)
        KeyboardShortcuts.onKeyDown(for: .collapse, action: self.collapse)
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
    
    func setWindowSize(isExpanded: Bool, animate: Bool = true) {
        guard self.isExpanded != isExpanded else { return }
        guard let window = windowController?.window else { return }
        let frame = window.frame
        let targetSize = isExpanded ? Self.size.expanded : Self.size.collapsed
        
        let edge: NSRectEdge
        if isExpanded {
            edge = expansionEdge(
                position: frame.origin.applying(.init(translationX: 0, y: Self.size.collapsed.height)),
                size: Self.size.expanded
            )
            expansionEdge = edge
        } else {
            edge = expansionEdge
        }
        
        switch edge {
        case .maxY:
            window.setFrame(
                .init(origin: frame.origin, size: targetSize),
                display: true, animate: animate
            )
        case .minY:
            window.setFrame(
                .init(
                    origin: .init(x: frame.origin.x, y: frame.origin.y + frame.size.height - targetSize.height),
                    size: targetSize
                ),
                display: true, animate: animate
            )
        default: break
        }
        
        self.isExpanded = isExpanded
    }
}

extension ClipHistoryViewController {
    // MARK: - Open / Close
    
    var isOpened: Bool {
        windowController != nil && windowController?.window?.isVisible == true
    }
    
    func open(position: CGPoint) {
        if let windowController {
            windowController.window?.setFrameOrigin(positionNear(position: position, size: Self.size.collapsed)
                .applying(.init(translationX: 0, y: -Self.size.collapsed.height)))
            windowController.window?.orderFrontRegardless()
            initShortcuts()
            enableShortcuts()
        return
        }
        
        let panel = FloatingPaneHleper(
            position: position,
            show: .constant(true)
        ) {
            ClipHistoryView()
                .modelContainer(for: ClipboardHistory.self, isUndoEnabled: true)
                .modelContainer(for: ClipboardContent.self, isUndoEnabled: true)
                .environment(\.viewController, self)
        }
        
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
        setWindowSize(isExpanded: false, animate: false)
        
        initShortcuts()
        enableShortcuts()
    }
    
    func close() {
        guard let windowController else { return }
        windowController.window?.orderOut(nil)
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
        setWindowSize(isExpanded: true)
    }
    
    func collapse() {
        setWindowSize(isExpanded: false)
    }
}
