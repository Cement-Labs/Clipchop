//
//  ClipHistoryViewController.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/17.
//

import SwiftUI
import Defaults
import KeyboardShortcuts

@Observable
class ClipHistoryPanelController: NSViewController, ObservableObject {
    
    static var size: (collapsed: NSSize, expanded: NSSize) {
        if Defaults[.displayMore] {
            return (
                collapsed: NSSize(width: 700, height: 140),
                expanded: NSSize(width: 700, height: 190)
            )
        } else {
            return (
                collapsed: NSSize(width: 500, height: 100),
                expanded: NSSize(width: 500, height: 150)
            )
        }
    }
        
    private var panel: ClipHistoryPanel?
    private var closeTimer: Timer?
    var isExpanded = false
    var isExpandedforView = false
    
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

extension ClipHistoryPanelController {
    // MARK: - Animations
    
    func setExpansion(_ isExpanded: Bool, animate: Bool = true) {
        guard self.isExpanded != isExpanded else { return }
        guard let panel = panel else { return }
        
        let frame = panel.frame
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
        
        withAnimation(.default) {
            isExpandedforView = isExpanded
        }
        
        resetCloseTimer()
        
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = animate ? 0.25 : 0
                context.allowsImplicitAnimation = animate
                
                switch edge {
                case .maxY:
                    panel.animator().setFrame(
                        .init(origin: frame.origin, size: targetSize),
                        display: true
                    )
                case .minY:
                    panel.animator().setFrame(
                        .init(
                            origin: .init(x: frame.origin.x, y: frame.origin.y + frame.size.height - targetSize.height),
                            size: targetSize
                        ),
                        display: true
                    )
                default: break
                }
            } completionHandler: {
                self.isExpanded = isExpanded
            }
        }
    }
}

extension ClipHistoryPanelController {
    // MARK: - Open / Close
    
    var isOpened: Bool {
        panel != nil && panel?.isVisible == true
    }
    
    func open(position: CGPoint) {
        DispatchQueue.main.async {
            guard let panel = self.panel else {
                // Initialize
                self.panel = .init(self)
                self.open(position: position)
                return
            }
            
            panel.setFrame(
                CGRect(
                    origin: self.positionNear(position: position, size: Self.size.collapsed)
                        .applying(.init(translationX: 0, y: -Self.size.collapsed.height)),
                    size: Self.size.collapsed
                ),
                display: false
            )
            panel.setFrameOrigin(
                self.positionNear(position: position, size: Self.size.collapsed)
                    .applying(.init(translationX: 0, y: -Self.size.collapsed.height))
            )
            
            panel.makeKeyAndOrderFront(nil)
            
            self.startCloseTimer()
            
            NotificationCenter.default.post(name: .panelDidOpen, object: nil)
        }
    }
    
    func close() {
        NotificationCenter.default.post(name: .panelDidClose, object: nil)
        if let window = self.panel {
            let frame = window.frame
            let windowPosition = ["x": frame.origin.x, "y": frame.origin.y + frame.height]
            UserDefaults.standard.set(windowPosition, forKey: "windowPosition")
        }
        self.setExpansion(false)
        self.panel?.orderOut(nil)
        panelDidClose()
    }
    
    func logoutpanel() {
        log(self, "Logout panel")
        NotificationCenter.default.post(name: .panelDidLogout, object: nil)
        self.setExpansion(false)
        self.panel?.orderOut(nil)
        self.panel = nil
        panelDidClose()
        
        
        if let contentView = panel?.contentView {
            contentView.subviews.forEach { $0.removeFromSuperview() }
            contentView.layoutSubtreeIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let newController = ClipHistoryPanelController()
            let newPanel = ClipHistoryPanel(newController)
            self.panel = newPanel
        }
    }
    
    func toggle(position: CGPoint) {
        if isOpened {
            close()
        } else {
            open(position: position)
        }
    }
    
    func startCloseTimer() {
        if Defaults[.autoClose] {
            closeTimer?.invalidate()
            let timeoutInterval = Defaults[.autoCloseTimeout]
            closeTimer = Timer.scheduledTimer(timeInterval: timeoutInterval, target: self, selector: #selector(closeDueToInactivity), userInfo: nil, repeats: false)
        }
    }

    @objc private func closeDueToInactivity() {
        close()
    }

    func resetCloseTimer() {
        if Defaults[.autoClose] {
            startCloseTimer()
        }
    }

    func panelDidClose() {
        if Defaults[.autoClose] {
            closeTimer?.invalidate()
            closeTimer = nil
        }
    }
}

extension ClipHistoryPanelController {
    // MARK: - Expand / Collapse
    
    func expand() {
        setExpansion(true)
    }
    
    func collapse() {
        setExpansion(false)
    }
}
