//
//  ColorPreviewPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/21.
//

import SwiftUI
import SwiftHEXColors

class ColorPreviewPage {
    static func from(_ colorHex: String) -> NSImage? {
        guard let color = NSColor(hexString: colorHex) else { return nil }
        
        let image = NSImage(size: NSSize(width: 80, height: 80))
        image.lockFocus()
        color.drawSwatch(in: NSRect(x: 0, y: 0, width: 80, height: 80))
        image.unlockFocus()
        
        return image
    }
}
