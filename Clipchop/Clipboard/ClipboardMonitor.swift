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
//        NSPasteboard.PasteboardType.html.rawValue,
        NSPasteboard.PasteboardType.string.rawValue,
        NSPasteboard.PasteboardType.fileURL.rawValue,
//        NSPasteboard.PasteboardType.URL.rawValue,
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
        guard let content else { return false }
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
            print("Error checking for duplicate content! \(error)")
            return true
        }
    }
    
    private func handleDuplicated(_ existing: [ClipboardContent]) throws {
        for exist in existing {
            if let history = exist.item {
                history.time = Date.now
                try context.save()
                
                break
            }
        }
    }
    
    private func updateClipboard() {
        try! context.save()
        
        guard ClipboardHistory.pasteboard.changeCount != changeCount else { return }
        changeCount = ClipboardHistory.pasteboard.changeCount
        
        if let sourceBundle = ClipboardHistory.source?.bundleIdentifier {
            print("Clipboard update detected in application \(sourceBundle)")
            if Defaults.shouldIgnoreApp(sourceBundle) {
                // Ignored
                return
            }
        } else {
            print("Clipboard update detected")
        }
        
//        let contents = ClipboardHistory.pasteboard.pasteboardItems?.compactMap { content in
//
//        }
        
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
               let rtfDataTemp = item.data(forType: NSPasteboard.PasteboardType.rtf) {
                rtfData = rtfDataTemp
            }
            
            if let fileURLData = fileURLData, !isNew(content: fileURLData) {
                return
            }
            
            if let rtfData = rtfData, !isNew(content: rtfData) {
                return
            }
            
            if hasFileURL {
                if let fileData = fileURLData {
                    let fileContent = ClipboardContent(type: NSPasteboard.PasteboardType.fileURL.rawValue, value: fileData)
                    contents.append(fileContent)
                }
            } else {
                types.forEach { type in
                    if allowedPasteboardTypes.contains(type.rawValue), let data = item.data(forType: type) {
                        if type != NSPasteboard.PasteboardType.fileURL, isNew(content: data) {
                            let content = ClipboardContent(type: type.rawValue, value: data)
                            contents.append(content)
                        }
                    }
                }
            }
        })
        Sound.currentSound.play()
        do {
            try context.save()
            print("The Contents of Clipboard are changed\(ClipboardHistory())")
        } catch {
            let nserror = error as NSError
            print("UnSaved error \(nserror), \(nserror.userInfo)")
        }
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
        print("Started monitoring")
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        print("Stopped monitoring")
    }
}
