//
//  Formatter.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import SwiftUI
import SwiftHEXColors

import AppKit
import Vision
import LinkPresentation

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
        return generateContentPreview()
    }
    
    func generateContentPreview() -> String {
        guard let firstContent = contents.first else {
            return ""
        }
        
        let cacheKey = generateCacheKey(from: firstContent)
        
        if let cachedPreview = MetadataCache.shared.getPreview(for: cacheKey) {
            return cachedPreview
        }
        
        var plainTextContents = [String]()
        
        contents.forEach { content in
            if let type = content.type {
                let pasteboardType = NSPasteboard.PasteboardType(type)
                switch pasteboardType {
                case .html:
                    if let htmlString = String(data: content.value!, encoding: .utf8) {
                        let plainText = extractPlainTextFromHTML(htmlString)
                        if !plainText.isEmpty {
                            plainTextContents.append(plainText)
                        }
                    }
                case .rtf:
                    if let rtfString = NSAttributedString(rtf: content.value!, documentAttributes: nil)?.string {
                        plainTextContents.append(rtfString)
                    }
                case .string:
                    if let text = String(data: content.value!, encoding: .utf8) {
                        plainTextContents.append(text)
                    }
                default:
                    break
                }
            }
        }
        
        let combinedPlainText = plainTextContents.joined(separator: "\n\n")
        var preview = combinedPlainText
        let semaphore = DispatchSemaphore(value: 0)
        
        if let firstContent = plainTextContents.first, !firstContent.isEmpty {
            if let url = NSURL(string: firstContent), url.scheme != nil {
                extractMetadataFromURL(url as URL) { title in
                    let urlPreview = title != nil ? "URL: \(title!)" : "URL: \(url.absoluteString ?? "")"
                    MetadataCache.shared.setPreview(urlPreview, for: cacheKey)
                }
            } else {
                MetadataCache.shared.setPreview(preview, for: cacheKey)
            }
        } else if let image = image {
            extractTextFromImage(image) { recognizedText in
                if let text = recognizedText, !text.isEmpty {
                    preview = text
                } else {
                    preview = "Image: \(image.size.width)x\(image.size.height)"
                }
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: .distantFuture)
        } else if let url = url {
            extractMetadataFromURL(url) { title in
                let preview = title != nil ? "URL: \(title!)" : "URL: \(url.absoluteString)"
                MetadataCache.shared.setPreview(preview, for: cacheKey)

            }
        } else if !fileURLs.isEmpty {
            var filePreview = "Files: \(fileURLs.map { $0.lastPathComponent }.joined(separator: ", "))"
            
            for fileURL in fileURLs {
                if let image = NSImage(contentsOf: fileURL) {
                    extractTextFromImage(image) { recognizedText in
                        if let text = recognizedText, !text.isEmpty {
                            filePreview += " \(fileURL.lastPathComponent): \(text)"
                        }
                        MetadataCache.shared.setPreview(filePreview, for: cacheKey)
                    }
                    break
                }
            }
            
            preview = filePreview
        }
        
        MetadataCache.shared.setPreview(preview, for: cacheKey)
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
    
    func extractMetadataFromURL(_ url: URL, completion: @escaping (String?) -> Void) {
        let metadataProvider = LPMetadataProvider()
        metadataProvider.startFetchingMetadata(for: url) { metadata, error in
            if let error = error {
                print("Error fetching metadata: \(error)")
                completion(nil)
            } else if let metadata = metadata, let title = metadata.title {
                completion(title)
            } else {
                completion(nil)
            }
        }
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
    
    func extractTextFromImage(_ image: NSImage, completion: @escaping (String?) -> Void) {
        autoreleasepool {
            guard let tiffData = image.tiffRepresentation,
                  let bitmapImage = NSBitmapImageRep(data: tiffData),
                  let cgImage = bitmapImage.cgImage else {
                completion(nil)
                return
            }
            
            log(self, "Run OCR")
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                    completion(nil)
                    return
                }
                
                let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                completion(recognizedText)
            }
            
            request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US"]
            request.recognitionLevel = .accurate
            
            do {
                try requestHandler.perform([request])
            } catch {
                completion(nil)
            }
        }
    }

    func extractTextFromImageFileURL(_ fileURL: URL, completion: @escaping (String?) -> Void) {
        guard let image = NSImage(contentsOf: fileURL) else {
            completion(nil)
            return
        }
        
        extractTextFromImage(image, completion: completion)
    }
    
    func generateCacheKey(from clipboardContent: ClipboardContent) -> String {
        guard let id = clipboardContent.item?.id else {
            fatalError("ClipboardContent must have a valid ClipboardHistory item with an id")
        }
        return id.uuidString
    }
}
