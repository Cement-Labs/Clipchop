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
    private let clipHistoryViewController: ClipHistoryPanelController
    private let allowedPasteboardTypes: Set<String> = [
        
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
    
    init (context: NSManagedObjectContext, clipHistoryViewController: ClipHistoryPanelController, clipboardModelManager: ClipboardModelManager) {
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
            log(self,"Error checking for duplicate content: \(error)")
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
                    log(self, "Error saving context: \(error)")
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
            var htmlData: Data?
            var rtfData: Data?
            var stringData: Data?
            
            if types.contains(NSPasteboard.PasteboardType.fileURL),
               let data = item.data(forType: NSPasteboard.PasteboardType.fileURL),
               let _ = URL(dataRepresentation: data, relativeTo: nil) {
                hasFileURL = true
                fileURLData = data
            }
            
            if types.contains(NSPasteboard.PasteboardType.rtf),
               let rtfDataTemp = item.data(forType: NSPasteboard.PasteboardType.rtf) {
                rtfData = rtfDataTemp
            }
            
            if types.contains(NSPasteboard.PasteboardType.html),
               let data = item.data(forType: NSPasteboard.PasteboardType.html) {
                htmlData = data
            }
            
            if types.contains(NSPasteboard.PasteboardType.string),
               let data = item.data(forType: NSPasteboard.PasteboardType.string) {
                stringData = data
            }
            
            if let fileURLData = fileURLData, !isNew(fileURLData) {
                return
            }
            
            if let rtfData = rtfData, !isNew(rtfData) {
                return
            }
            
            if let htmlData = htmlData, !isNew(htmlData) {
                return
            }
            
            if let stringData = stringData, !isNew(stringData) {
                return
            }
            
            if hasFileURL {
                if let fileData = fileURLData {
                    let fileContent = ClipboardContent(type: NSPasteboard.PasteboardType.fileURL.rawValue, value: fileData)
                    contents.append(fileContent)
                }
            } else {
                if let htmlData = htmlData {
                    let content = ClipboardContent(type: NSPasteboard.PasteboardType.html.rawValue, value: htmlData)
                    contents.append(content)
                }
                else if let rtfData = rtfData {
                    let content = ClipboardContent(type: NSPasteboard.PasteboardType.rtf.rawValue, value: rtfData)
                    contents.append(content)
                }
                else if let stringData = stringData {
                    let content = ClipboardContent(type: NSPasteboard.PasteboardType.string.rawValue, value: stringData)
                    contents.append(content)
                }
                
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
        }
        
        do {
            try context.save()
            let formatter = Formatter(contents: contents)
            formatter.categorizeFileTypes()
            log(self,"The Contents of Clipboard are changed\(ClipboardHistory(contents: contents))")
            log(self, "title = \(formatter.title ?? "EMPTY")")
        } catch {
            let nserror = error as NSError
            log(self, "UnSaved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Copy to Clipboard
    
    func copy(_ item: ClipboardHistory?) {
        guard let item = item else {
            return
        }
        
        var contents = item.getContents()
        pasteboard.clearContents()
        
        if Defaults[.removeFormatting] {
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
            contents = plainTextContents
        } else {
            var plainTextContent: ClipboardContent?
            contents.forEach { content in
                if let type = content.type, NSPasteboard.PasteboardType(type) == .html {
                    if let htmlString = String(data: content.value!, encoding: .utf8) {
                        let plainText = extractPlainTextFromHTML(htmlString)
                        if let plainTextData = plainText.data(using: .utf8) {
                            plainTextContent = ClipboardContent(type: NSPasteboard.PasteboardType.string.rawValue, value: plainTextData)
                        }
                    }
                }
            }
           
            if let plainTextContent = plainTextContent {
                contents.append(plainTextContent)
            }
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
    
    private func extractPlainTextFromHTML(_ html: String) -> String {
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
