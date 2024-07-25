//
//  ColorPreviewPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/21.
//

import SwiftUI
import Defaults
import SwiftHEXColors

class ColorPreviewPage {
    static func from(_ colorHex: String) -> NSImage? {
        guard let color = NSColor(hexString: colorHex) else { return nil }
        
        let image = NSImage(size: NSSize(width: Defaults[.displayMore] ? 80 : 112, height: Defaults[.displayMore] ? 80 : 112))
        image.lockFocus()
        color.drawSwatch(in: NSRect(x: 0, y: 0, width: Defaults[.displayMore] ? 80 : 112, height: Defaults[.displayMore] ? 80 : 112))
        image.unlockFocus()
        
        return image
    }
}

