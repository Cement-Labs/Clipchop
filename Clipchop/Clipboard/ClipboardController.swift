//
//  ClipboardController.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import AppKit
import Defaults

class ClipboardController: NSObject, ObservableObject {
    
    @Published var started: Bool = false {
        didSet {
            if started {
                start()
            } else {
                stop()
            }
        }
    }
    
    private var timer: Timer?
    private var changeCount: Int = 0
    
    private let context: NSManagedObjectContext
    private let pasteboard = NSPasteboard.general
    private let clipboardModelManager: ClipboardModelManager
    private let clipHistoryViewController: ClipHistoryPanelController
    private let allowedPasteboardTypes: Set<String> = [
        
        NSPasteboard.PasteboardType.URL.rawValue,
        NSPasteboard.PasteboardType.string.rawValue,
        NSPasteboard.PasteboardType.jpeg.rawValue,
        NSPasteboard.PasteboardType.tiff.rawValue,
        NSPasteboard.PasteboardType.png.rawValue,
        NSPasteboard.PasteboardType.avif.rawValue,
        NSPasteboard.PasteboardType.pdf.rawValue,
        
        NSPasteboard.PasteboardType.tabularText.rawValue,
        NSPasteboard.PasteboardType.multipleTextSelection.rawValue,
        NSPasteboard.PasteboardType.fileContents.rawValue,
        
        NSPasteboard.PasteboardType.universalClipboard.rawValue,
        NSPasteboard.PasteboardType.appleFinalCutPro.rawValue,
        NSPasteboard.PasteboardType.modified.rawValue,
        NSPasteboard.PasteboardType.microsoftLinkSource.rawValue,
        NSPasteboard.PasteboardType.microsoftObjectLink.rawValue,
        NSPasteboard.PasteboardType.autoGenerated.rawValue,
        NSPasteboard.PasteboardType.concealed.rawValue,
        NSPasteboard.PasteboardType.transient.rawValue
    ]
    
    init (context: NSManagedObjectContext, clipHistoryViewController: ClipHistoryPanelController, clipboardModelManager: ClipboardModelManager) {
        self.started = true
        self.context = context
        self.clipboardModelManager = clipboardModelManager
        self.clipHistoryViewController = clipHistoryViewController
        self.changeCount = ClipboardHistory.pasteboard.changeCount
    }
    
    // MARK: - Clipboard Change

    private func isNew(_ content: Data?) -> Bool {
        guard let content = content else { return false }
        let fetchRequest: NSFetchRequest<ClipboardContent> = NSFetchRequest<ClipboardContent>(entityName: "ClipboardContent")
        fetchRequest.predicate = NSPredicate(format: "value == %@", content as CVarArg)
        do {
            let existingItems = try context.fetch(fetchRequest)
            if !existingItems.isEmpty {
                log(self, "OLD")
                handleDuplicated(existingItems)
                return false
            } else {
                log(self, "NEW")
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
                    DispatchQueue.main.async {
                        do {
                            try self.context.save()
                            log(self, "Context saved successfully")
                        } catch {
                            log(self, "Error saving context: \(error)")
                        }
                    }
                    break
                }
            }
        }
    }
    
    // MARK: - Update clipboard history
    
    private func updateClipboard() {
        
        guard pasteboard.changeCount != changeCount else {
            return
        }
        
        try? context.save()
        
        changeCount = pasteboard.changeCount
        
        if let sourceBundle = ClipboardHistory.source?.bundleIdentifier {
            if Defaults.shouldIgnoreApp(sourceBundle) {
                return
            }
        } else {
            log(self, "Clipboard update detected")
        }
        
        var contents: [ClipboardContent] = []
        var hasFileURL = false
        var hasHTML = false
        var hasRTF = false
        
        pasteboard.pasteboardItems?.forEach { item in
            let types = Set(item.types)
            var fileURLData: Data?
            var htmlData: Data?
            var rtfData: Data?
            
            if types.contains(NSPasteboard.PasteboardType.fileURL),
               let data = item.data(forType: NSPasteboard.PasteboardType.fileURL),
               let _ = URL(dataRepresentation: data, relativeTo: nil) {
                hasFileURL = true
                fileURLData = data
            }
            
            if types.contains(NSPasteboard.PasteboardType.html),
               let data = item.data(forType: NSPasteboard.PasteboardType.html) {
                hasHTML = true
                htmlData = data
            }
            
            if types.contains(NSPasteboard.PasteboardType.rtf),
               let data = item.data(forType: NSPasteboard.PasteboardType.rtf) {
                hasRTF = true
                rtfData = data
            }
            
            // Check data type priority and avoid duplicates
            if hasFileURL {
                if let fileData = fileURLData, isNew(fileData) {
                    let fileContent = ClipboardContent(type: NSPasteboard.PasteboardType.fileURL.rawValue, value: fileData)
                    contents.append(fileContent)
                }
            } else if hasHTML {
                if let htmlData = htmlData, isNew(htmlData) {
                    let content = ClipboardContent(type: NSPasteboard.PasteboardType.html.rawValue, value: htmlData)
                    contents.append(content)
                }
            } else if hasRTF {
                if let rtfData = rtfData, isNew(rtfData) {
                    let content = ClipboardContent(type: NSPasteboard.PasteboardType.rtf.rawValue, value: rtfData)
                    contents.append(content)
                }
            }
            // Handle other types only if no preferred types are present
            if !hasFileURL && !hasHTML && !hasRTF {
                types.forEach { type in
                    if allowedPasteboardTypes.contains(type.rawValue), let data = item.data(forType: type) {
                        if isNew(data) {
                            let content = ClipboardContent(type: type.rawValue, value: data)
                            contents.append(content)
                        }
                    }
                }
            }
        }
        
        guard !contents.isEmpty else {
            return
        }
        
        DispatchQueue.main.async {
            Notification.Name.didClip.post()
            do {
                try self.context.save()
                let formatter = Formatter(contents: contents)
                formatter.categorizeFileTypes()
                log(self, "The contents of Clipboard have changed \(ClipboardHistory(contents: contents))")
                log(self, "title = \(formatter.title ?? "EMPTY")")
                formatter.generateContentPreview()
            } catch {
                let nserror = error as NSError
                log(self, "UnSaved error \(nserror), \(nserror.userInfo)")
            }
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
            var originalHTMLContent: ClipboardContent?

            contents.forEach { content in
                if let type = content.type, NSPasteboard.PasteboardType(type) == .html {
                    if let htmlString = String(data: content.value!, encoding: .utf8) {
                        let plainText = extractPlainTextFromHTML(htmlString)
                        if let plainTextData = plainText.data(using: .utf8) {
                            plainTextContent = ClipboardContent(type: NSPasteboard.PasteboardType.string.rawValue, value: plainTextData)
                        }
                        originalHTMLContent = content
                    }
                }
            }
            if let originalHTMLContent = originalHTMLContent {
                contents.append(originalHTMLContent)
            }
            
            if let plainTextContent = plainTextContent {
                contents.append(plainTextContent)
            }
        }
        
        let nonFileURLContents = contents.filter { content in
            content.type != NSPasteboard.PasteboardType.fileURL.rawValue
        }
        
        nonFileURLContents.forEach { content in
            if let type = content.type {
                pasteboard.setData(content.value, forType: NSPasteboard.PasteboardType(type))
            }
        }
        
        let fileURLItems: [NSPasteboardItem] = contents.compactMap { content in
            guard content.type == NSPasteboard.PasteboardType.fileURL.rawValue else { return nil }
            guard let value = content.value else { return nil }
            let pasteItem = NSPasteboardItem()
            pasteItem.setData(value, forType: NSPasteboard.PasteboardType(content.type ?? ""))
            return pasteItem
        }
        pasteboard.writeObjects(fileURLItems)
        
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
        
        changeCount = pasteboard.changeCount
        
        clipboardModelManager.startPeriodicCleanup()
        
        timer = Timer.scheduledTimer(withTimeInterval: Defaults[.timerInterval], repeats: true) { [weak self] _ in
            self?.updateClipboard()
        }
        
        RunLoop.main.add(timer!, forMode: .common)
        
        if Defaults[.sendNotification] {
            sendStartNotification()
        }
        
        log(self, "Started monitoring")
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        clipboardModelManager.stopPeriodicCleanup()
        if Defaults[.sendNotification] {
            sendStopNotification()
        }
        log(self, "Stopped monitoring")
    }
    
    func toggle() {
        started.toggle()
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
    
    private func sendStartNotification() {
        let title = NSLocalizedString("Clipboard Started", comment: "Title for start notification")
        let body = NSLocalizedString("The clipboard monitoring has been started.", comment: "Body for start notification")
        AppDelegate.sendNotification(title, body)
    }

    private func sendStopNotification() {
        let title = NSLocalizedString("Clipboard Stopped", comment: "Title for stop notification")
        let body = NSLocalizedString("The clipboard monitoring has been stopped.", comment: "Body for stop notification")
        AppDelegate.sendNotification(title, body)
    }
}
