//
//  Formatter.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import Foundation
import SwiftUI
import AppKit

struct Formatter {
    var contents: [ClipboardContent]
    
    var universalHasImage: Bool {
        isUniversal && fileURLs.first?.pathExtension == NSPasteboard.PasteboardType.jpeg.rawValue
    }
    var universalHasText: Bool {
        isUniversal && contentData(
            ClipboardHistorya.Class.html.types
            + ClipboardHistorya.Class.image.types
            + ClipboardHistorya.Class.rtf.types
            + ClipboardHistorya.Class.text.types
        ) != nil
    }
    var isUniversal: Bool { contentData([.universalClipboard]) != nil }
    var fromClipchop: Bool { contentData([.fromClipchop]) != nil }
    
    func contentData(_ types: [NSPasteboard.PasteboardType]) -> Data? {
        contents.first { content in
            types.contains(.init(content.type!))
        }?.value
    }
    
    func allContentData(_ types: [NSPasteboard.PasteboardType]) -> [Data] {
        contents
            .filter { types.contains(NSPasteboard.PasteboardType($0.type!)) }
            .compactMap { $0.value }
    }
}

extension Formatter {
    var fileURLs: [URL] {
        guard !universalHasText else { return [] }
        return allContentData(ClipboardHistorya.Class.file.types)
            .compactMap { URL(dataRepresentation: $0, relativeTo: nil, isAbsolute: true) }
    }
    
    var htmlData: Data? {
        contentData(ClipboardHistorya.Class.html.types)
    }
    
    var htmlString: NSAttributedString? {
        guard let htmlData else { return nil }
        return .init(html: htmlData, documentAttributes: nil)
    }
    
    var image: NSImage? {
        var data = contentData(ClipboardHistorya.Class.image.types)
        if data == nil, universalHasImage, let url = fileURLs.first {
            data = try? Data(contentsOf: url)
        }
        
        guard let data else { return nil }
        return .init(data: data)
    }
    
    var rtfData: Data? {
        contentData(ClipboardHistorya.Class.rtf.types)
    }
    
    var rtfString: NSAttributedString? {
        guard let rtfData else { return nil }
        return .init(rtf: rtfData, documentAttributes: nil)
    }
    
    var text: String? {
        guard let data = contentData(ClipboardHistorya.Class.text.types)
        else { return nil }
        return .init(data: data, encoding: .utf8)
    }
}

extension Formatter {
    var title: String? {
        var result: String? = nil
        let fileExtensions = fileURLs.map { $0.pathExtension }.sorted()
        
        if image != nil {
            // Image
            result = String(localized: "Type: Image", defaultValue: "Image")
        } else if !fileExtensions.isEmpty {
            if fileExtensions.count > 1 {
                // Multiple files
                result = String(localized: "Type: Mixed", defaultValue: "Multiple")
            } else {
                // Single file
                result = fileExtensions.first!
            }
        }
        
        if let text, !text.isEmpty {
            // Plain text
            var type = String(localized: "Type: Text", defaultValue: "Plain Text")
            
            if let _ = URL(string: text) {
                // Link
                type = String(localized: "Type: Link", defaultValue: "Link")
            } else if let _ = NSColor(hexString: text) {
                // Hex color
                type = String(localized: "Type: Color", defaultValue: "Color")
            }
            
            if result == nil {
                // Replace with
                result = type
            } else {
                // Append special type
                result = String(
                    format: .init(localized: "Type: Combined", defaultValue: "%1$@ (%2$@)"),
                    result!, type
                )
            }
        }
        
        return result
    }
}
