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
    static let size = (
        collapsed: NSSize(width: 500, height: 100),
        expanded: NSSize(width: 500, height: 260)
    )
    
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
           print("isExpandedforView")
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
                print("isExpanded")
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
        guard let panel else {
            // Initialize
            panel = .init(self)
            open(position: position)
            return
        }
        
        panel.setFrame(
            CGRect(
                origin: positionNear(position: position, size: Self.size.collapsed)
                    .applying(.init(translationX: 0, y: -Self.size.collapsed.height)),
                size: Self.size.collapsed
            ),
            display: false
        )
        panel.setFrameOrigin(
            positionNear(position: position, size: Self.size.collapsed)
                .applying(.init(translationX: 0, y: -Self.size.collapsed.height))
        )
        
        panel.makeKeyAndOrderFront(nil)
        startCloseTimer()
    }
    
    func close() {
        self.setExpansion(false)
        self.panel?.orderOut(nil)
        panelDidClose()
    }
    
    func toggle(position: CGPoint) {
        if isOpened {
            close()
        } else {
            open(position: position)
        }
    }
    
    func startCloseTimer() {
        closeTimer?.invalidate()
        let timeoutInterval = Defaults[.autoCloseTimeout]
        closeTimer = Timer.scheduledTimer(timeInterval: timeoutInterval, target: self, selector: #selector(closeDueToInactivity), userInfo: nil, repeats: false)
    }

    @objc private func closeDueToInactivity() {
        close()
    }

    func resetCloseTimer() {
        startCloseTimer()
    }

    func panelDidClose() {
        closeTimer?.invalidate()
        closeTimer = nil
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
