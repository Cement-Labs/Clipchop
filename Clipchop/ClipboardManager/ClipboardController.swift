//
//  ClipboardController.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import AppKit
import Defaults

class ClipboardController: NSObject {
    
    private var started: Bool
    private var timer: Timer?
    private var changeCount: Int = 0
    
    private let context: NSManagedObjectContext
    private let pasteboard = NSPasteboard.general
    private let clipboardModelManager: ClipboardModelManager
    private let clipHistoryViewController: ClipHistoryViewController
    private let allowedPasteboardTypes: Set<String> = [
        
        NSPasteboard.PasteboardType.rtf.rawValue,
        NSPasteboard.PasteboardType.rtfd.rawValue,
        NSPasteboard.PasteboardType.string.rawValue,
        
        NSPasteboard.PasteboardType.fileURL.rawValue,
        NSPasteboard.PasteboardType.URL.rawValue,
        NSPasteboard.PasteboardType.html.rawValue,
        
        NSPasteboard.PasteboardType.jpeg.rawValue,
        NSPasteboard.PasteboardType.tiff.rawValue,
        NSPasteboard.PasteboardType.png.rawValue,
        NSPasteboard.PasteboardType.pdf.rawValue,
        
        NSPasteboard.PasteboardType.universalClipboard.rawValue,
        NSPasteboard.PasteboardType.tabularText.rawValue,
        NSPasteboard.PasteboardType.multipleTextSelection.rawValue,
        NSPasteboard.PasteboardType.fileContents.rawValue
    ]
    
    init (context: NSManagedObjectContext, clipHistoryViewController: ClipHistoryViewController, clipboardModelManager: ClipboardModelManager) {
        changeCount = pasteboard.changeCount
        
        self.started = true
        self.context = context
        self.clipboardModelManager = clipboardModelManager
        self.clipHistoryViewController = clipHistoryViewController
        self.changeCount = ClipboardHistory.pasteboard.changeCount
        
        super.init()
    }
    
    // MARK: - Clipboard Change

    private func isNew(_ content: Data?) -> Bool {
        guard let content = content else { return false }
        let fetchRequest: NSFetchRequest<ClipboardContent> = NSFetchRequest<ClipboardContent>(entityName: "ClipboardContent")
        fetchRequest.predicate = NSPredicate(format: "value == %@", content as CVarArg)
        do {
            let existingItems = try context.fetch(fetchRequest)
            if !existingItems.isEmpty {
                handleDuplicated(existingItems)
                return false
            } else {
                return true
            }
        } catch {
            print("Error checking for duplicate content: \(error)")
            return true
        }
    }
    
    private func handleDuplicated(_ existingItems: [ClipboardContent]) {
        for existingItem in existingItems {
            if let history = existingItem.item {
                history.time = Date()
                do {
                    try context.save()
                    break
                } catch {
                    print("Error saving context: \(error)")
                }
            }
        }
    }
    
    // MARK: - Update clipboard history
    private func updateClipboard() {
        
        try! context.save()
                
        guard pasteboard.changeCount != changeCount else {
            return
        }
        
        changeCount = pasteboard.changeCount
        
        if let sourceBundle = ClipboardHistory.source?.bundleIdentifier {
            log(self, "Clipboard update detected in application \(sourceBundle)")
            if Defaults.shouldIgnoreApp(sourceBundle) {
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
               let rtfDataTemp = item.data(forType: NSPasteboard.PasteboardType.rtf) {
                rtfData = rtfDataTemp
            }
            
            if let fileURLData = fileURLData, !isNew(fileURLData) {
                return
            }
            
            if let rtfData = rtfData, !isNew(rtfData) {
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
                        if type != NSPasteboard.PasteboardType.fileURL, isNew(data) {
                            let content = ClipboardContent(type: type.rawValue, value: data)
                            contents.append(content)
                        }
                    }
                }
            }
        })
        
        guard !contents.isEmpty else {
            return
        }
        DispatchQueue.main.async {
            Notification.Name.didClip.post()
            log(self, "Notified clipboard change")
        }
        do {
            try context.save()
            let formatter = Formatter(contents: contents)
            formatter.categorizeFileTypes()
            log(self,"The Contents of Clipboard are changed\(ClipboardHistory(contents: contents))")
            log(self, "\(formatter.title ?? "EMPTY")")
        } catch {
            let nserror = error as NSError
            log(self, "UnSaved error \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Copy to Clipboard

    func copy(_ item: ClipboardHistory?, removeFormatting: Bool = false) {
        guard let item = item else {
            return
        }

        var contents = item.getContents()

        pasteboard.clearContents()

        if removeFormatting {
            contents = contents.filter { NSPasteboard.PasteboardType($0.type!) == .string }
        }

        contents.forEach { content in
            if let type = content.type {
                pasteboard.setData(content.value, forType: NSPasteboard.PasteboardType(type))
            }
        }
        
        DispatchQueue.main.async {
            Notification.Name.didPaste.post()
        }

        if Defaults[.pasteToFrontmostEnabled] {
            clipHistoryViewController.close()
            pasteToActiveApplication()
        }
    }
    
    func pasteToActiveApplication() {
        PermissionsManager.Accessibility.requestAccess()
        
        // Simulate Cmd+V keypress to paste
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true) // Cmd+V down
        keyDownEvent?.flags = .maskCommand
        keyDownEvent?.post(tap: .cghidEventTap)
        
        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false) // Cmd+V up
        keyUpEvent?.flags = .maskCommand
        keyUpEvent?.post(tap: .cghidEventTap)
    }
}

extension ClipboardController {
    // MARK: - Monitoring Functions
    
    func start() {
        
        clipboardModelManager.startPeriodicCleanup()
        
        timer = .scheduledTimer(withTimeInterval: Defaults[.timerInterval], repeats: true ) { [weak self] _ in
            self?.updateClipboard()
        }
        
        log(self, "Started monitoring")
    }
    
    
    func stop() {
        timer?.invalidate()
        timer = nil
        
        log(self, "Stopped monitoring")
    }
    
    func toggle() {
        if started {
            stop()
            started = false
        } else {
            pasteboard.clearContents()
            start()
            started = true
        }
    }
}
