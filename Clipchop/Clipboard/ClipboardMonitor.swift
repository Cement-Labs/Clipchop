//
//  ClipboardMonitor.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import SwiftUI
import AppKit
import Defaults
import SwiftData

class ClipboardMonitor: NSObject {
    private var timer: Timer?
    private var changeCount: Int = 0
    private var context: ModelContext
    
    private let pasteboard = NSPasteboard.general
    private let allowedPasteboardTypes: Set<String> = [
        NSPasteboard.PasteboardType.rtf.rawValue,
        NSPasteboard.PasteboardType.rtfd.rawValue,
        NSPasteboard.PasteboardType.html.rawValue,
        NSPasteboard.PasteboardType.string.rawValue,
        NSPasteboard.PasteboardType.fileURL.rawValue,
        NSPasteboard.PasteboardType.URL.rawValue,
        NSPasteboard.PasteboardType.jpeg.rawValue,
        NSPasteboard.PasteboardType.tiff.rawValue,
        NSPasteboard.PasteboardType.png.rawValue,
        NSPasteboard.PasteboardType.pdf.rawValue,
        NSPasteboard.PasteboardType.universalClipboard.rawValue,
        NSPasteboard.PasteboardType.tabularText.rawValue,
        NSPasteboard.PasteboardType.multipleTextSelection.rawValue,
        NSPasteboard.PasteboardType.fileContents.rawValue
    ]
    
    init(context: ModelContext) {
        self.context = context
        self.changeCount = ClipboardHistory.pasteboard.changeCount
    }
    
    // MARK: - Clipboard Change
    
    private func isNew(content: Data?) -> Bool {
        guard let content = content else { return false }
        
        let existing = FetchDescriptor<ClipboardContent>(
            predicate: #Predicate { $0.value == content }
        )
        
        do {
            let existingResult = try context.fetch(existing)
            if !existingResult.isEmpty {
                // Duplicated
                try handleDuplicated(existingResult)
                
                return false
            } else {
                return true
            }
        } catch {
            log(self, "Error checking for duplicate content! \(error)")
            return false
        }
    }
    
    private func handleDuplicated(_ existing: [ClipboardContent]) throws {
        for exist in existing {
            if let history = exist.item {
                history.time = Date.now
                context.insert(history)
                
                break
            }
        }
    }
    
    private func updateClipboard() {
        guard ClipboardHistory.pasteboard.changeCount != changeCount else { return }
        changeCount = ClipboardHistory.pasteboard.changeCount
        
        if let sourceBundle = ClipboardHistory.source?.bundleIdentifier {
            log(self, "Clipboard update detected in application \(sourceBundle)")
            if Defaults.shouldIgnoreApp(sourceBundle) {
                // Ignored
                return
            }
        } else {
            log(self, "Clipboard update detected")
        }
        
        var contents: [ClipboardContent] = []

        pasteboard.pasteboardItems?.forEach({ item in
            let types = Set(item.types)
            var hasFileURL = false
            var fileURLData: Data?
            var rtfData: Data?
            
            if types.contains(NSPasteboard.PasteboardType.fileURL),
               let data = item.data(forType: NSPasteboard.PasteboardType.fileURL),
               let _ = URL(dataRepresentation: data, relativeTo: nil) {
                hasFileURL = true
                fileURLData = data
            }
            
            if types.contains(NSPasteboard.PasteboardType.string),
               let rtfDataTemp = item.data(forType: NSPasteboard.PasteboardType.string) {
                rtfData = rtfDataTemp
            }
            
            if let fileURLData = fileURLData, !isNew(content: fileURLData) {
                return
            }
            
            if let rtfData = rtfData, !isNew(content: rtfData) {
                return
            }
            
            let clipboardHistory = ClipboardHistory()
            context.insert(clipboardHistory)
            
            if hasFileURL {
                if let fileData = fileURLData {
                    let fileContent = ClipboardContent(type: NSPasteboard.PasteboardType.fileURL.rawValue, value: fileData, item: clipboardHistory)
                    contents.append(fileContent)
                    context.insert(fileContent)
                }
            } else {
                types.forEach { type in
                    if allowedPasteboardTypes.contains(type.rawValue), let data = item.data(forType: type) {
                        if type != NSPasteboard.PasteboardType.fileURL, isNew(content: data) {
                            let content = ClipboardContent(type: type.rawValue, value: data, item: clipboardHistory)
                            contents.append(content)
                            context.insert(content)
                        }
                    }
                }
            }
        })
        
        guard !contents.isEmpty else {
            log(self, "No clipboard change happened")
            return
        }
        
        DispatchQueue.main.async {
            Notification.Name.didClip.post()
            log(self, "Notified clipboard change")
        }
        
        let formatter = Formatter(contents: contents)
        formatter.categorizeFileTypes()
        
#if DEBUG
        if let title = formatter.title {
            log(self, "Formatted title: \(title)")
        }
        contents.forEach { content in
            log(self, "[Content] Type: \(String(describing: content.type)), Value: \(content.value.debugDescription)")
        }
#endif
    }
}

extension ClipboardMonitor {
    // MARK: - Monitoring Functions
    
    func start() {
        timer = .scheduledTimer(
            withTimeInterval: Defaults[.timerInterval],
            repeats: true
        ) { [weak self] _ in
            self?.updateClipboard()
        }
        
        log(self, "Started monitoring")
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        
        log(self, "Stopped monitoring")
    }
}
