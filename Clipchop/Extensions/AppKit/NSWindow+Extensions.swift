//
//  NSWindow+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/25.
//

import AppKit

extension NSWindow {
    var standardWindowButtons: [ButtonType: NSButton?] {
        [
            .closeButton: standardWindowButton(.closeButton),
            .documentIconButton: standardWindowButton(.documentIconButton),
            .documentVersionsButton: standardWindowButton(.documentVersionsButton),
            .miniaturizeButton: standardWindowButton(.miniaturizeButton),
            .toolbarButton: standardWindowButton(.toolbarButton),
            .zoomButton: standardWindowButton(.zoomButton)
        ]
    }
    
    var availableStandardWindowButtons: [ButtonType: NSButton] {
        standardWindowButtons
            .compactMapValues { $0 }
    }
    
    var visibleWindowButtonTypes: [ButtonType] {
        get {
            availableStandardWindowButtons
                .filter { !$0.value.isHidden }
                .keys
                .map { $0 }
        }
        
        set {
            availableStandardWindowButtons.forEach { entry in
                entry.value.isHidden = !newValue.contains([entry.key])
            }
        }
    }
}
