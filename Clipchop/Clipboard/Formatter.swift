//
//  Formatter.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import SwiftUI
import SwiftHEXColors
import AppKit
import Defaults

struct Formatter {
    var contents: [ClipboardContent]
    
    var universalHasImage: Bool {
        isUniversal && fileURLs.first?.pathExtension == NSPasteboard.PasteboardType.jpeg.rawValue
    }
    var universalHasText: Bool {
        isUniversal && contentData(
            ClipboardHistory.Class.html.types
            + ClipboardHistory.Class.image.types
            + ClipboardHistory.Class.rtf.types
            + ClipboardHistory.Class.text.types
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
        return allContentData(ClipboardHistory.Class.file.types)
            .compactMap { URL(dataRepresentation: $0, relativeTo: nil, isAbsolute: true) }
    }
    
    var htmlData: Data? {
        contentData(ClipboardHistory.Class.html.types)
    }
    
    var htmlString: NSAttributedString? {
        guard let htmlData else { return nil }
        return .init(html: htmlData, documentAttributes: nil)
    }
    
    var image: NSImage? {
        var data = contentData(ClipboardHistory.Class.image.types)
        if data == nil, universalHasImage, let url = fileURLs.first {
            data = try? Data(contentsOf: url)
        }
        
        guard let data else { return nil }
        return .init(data: data)
    }
    
    var rtfData: Data? {
        contentData(ClipboardHistory.Class.rtf.types)
    }
    
    var rtfString: NSAttributedString? {
        guard let rtfData else { return nil }
        return .init(rtf: rtfData, documentAttributes: nil)
    }
    
    var text: String? {
        guard let data = contentData(ClipboardHistory.Class.text.types)
        else { return nil }
        return .init(data: data, encoding: .utf8)
    }
    
    var url: URL? {
        guard let data = contentData(ClipboardHistory.Class.url.types)
        else { return nil }
        return URL(dataRepresentation: data, relativeTo: nil, isAbsolute: true)
    }
}

extension Formatter {
    var title: String? {
        var result: String? = nil
        let fileExtensions = fileURLs.map { $0.pathExtension }.sorted()
        let folderCount = fileURLs.filter { url in
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
            return isDirectory.boolValue
        }.count
        
        if image != nil {
            // Image
            result = String(localized: "Type: Image", defaultValue: "Image")
        }  else if folderCount > 0 {
            if folderCount == 1 {
                // Single folder
                result = String(localized: "Type: Folder", defaultValue: "Folder")
            } else {
                // Multiple folders
                result = String(
                    format: .init(localized: "Type: %d Folders", defaultValue: "%d Folders"),
                    folderCount
                )
            }
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
            var type = String(localized: "Type: Text", defaultValue: "Text")
            
            if let url = NSURL(string: text), url.scheme != nil {
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
        
        if url != nil {
            let type = String(localized: "Type: Link", defaultValue: "Link")
            if result == nil {
                result = type
            } else {
                result = String(
                    format: .init(localized: "Type: Combined", defaultValue: "%1$@ (%2$@)"),
                    result!, type
                )
            }
        }
        
        if htmlData != nil {
            let type = String(localized: "Type: HTML", defaultValue: "Text")
            if result == nil {
                result = type
            } else {
                result = String(
                    format: .init(localized: "Type: Combined", defaultValue: "%1$@ (%2$@)"),
                    result!, type
                )
            }
        }
        
        if rtfData != nil {
            let type = String(localized: "Type: RTF", defaultValue: "Text")
            if result == nil {
                result = type
            } else {
                result = String(
                    format: .init(localized: "Type: Combined", defaultValue: "%1$@ (%2$@)"),
                    result!, type
                )
            }
        }
        
        return result
    }
    
    var contentPreview: String {
        
        var plainTextContents = [ClipboardContent]()
                
        contents.forEach { content in
            if let type = content.type {
                let pasteboardType = NSPasteboard.PasteboardType(type)
                switch pasteboardType {
                case .html:
                    if let htmlString = String(data: content.value!, encoding: .utf8) {
                        let plainText = extractPlainTextFromHTML(htmlString)
                        if let plainTextData = plainText.data(using: .utf8) {
                            plainTextContents.append(ClipboardContent(type: NSPasteboard.PasteboardType.string.rawValue, value: plainTextData))
                        }
                    }
                case .rtf:
                    if let rtfString = NSAttributedString(rtf: content.value!, documentAttributes: nil)?.string {
                        if let plainTextData = rtfString.data(using: .utf8) {
                            plainTextContents.append(ClipboardContent(type: NSPasteboard.PasteboardType.string.rawValue, value: plainTextData))
                        }
                    }
                case .string:
                    plainTextContents.append(content)
                default:
                    break
                }
            }
        }
        
        var preview = ""
        
        if let firstContent = plainTextContents.first, let text = String(data: firstContent.value!, encoding: .utf8), !text.isEmpty {
            preview = text
        } else if let image = image {
            preview = "Image: \(image.size.width)x\(image.size.height)"
        } else if let url = url {
            preview = "URL: \(url.absoluteString)"
        } else if !fileURLs.isEmpty {
            preview = "Files: \(fileURLs.map { $0.lastPathComponent }.joined(separator: ", "))"
        }
        
        return preview
    }
    
    func categorizeFileTypes() {
        guard let result = self.title?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else {
            log(self, "Title is nil or empty for \(self)")
            return
        }
        
        var allTypes = Set(Defaults[.allTypes].map { $0.lowercased() })
        let categories = Defaults[.categories]
        
        var categorized = false
        for category in categories {
            if category.types.contains(result) {
                log(self, "File type \(result) categorized under \(category.name)")
                categorized = true
                break
            }
        }
        
        if !categorized {
            log(self, "File type \(result) not categorized, needs manual categorization")
            if !allTypes.contains(result) {
                allTypes.insert(result)
            }
        }
        
        Defaults[.allTypes] = Array(allTypes)
    }
    
    func extractPlainTextFromHTML(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else {
            return html
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return html
        }

        return attributedString.string
    }
}

