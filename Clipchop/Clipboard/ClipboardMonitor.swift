//
//  ClipboardMonitor.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import SwiftUI
import AppKit
import Defaults

class ClipboardMonitor: NSObject {
    private var timer: Timer?
    private var changeCount: Int = 0
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.changeCount = ClipboardHistory.pasteboard.changeCount
        
        super.init()
    }
    
    // MARK: - Clipboard Change
    
    private func isNew(content: Data?) -> Bool {
        guard let content else { return false }
        let fetchRequest = ClipboardContent.fetchRequest()
        fetchRequest.predicate = .init(format: "\(ClipboardContent.Managed.value) == \(content)")
        
        do {
            let existing = try context.fetch(fetchRequest)
            if !existing.isEmpty {
                // Duplicated
                try handleDuplicated(existing)
                
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
        
        /*
        let contents = ClipboardHistory.pasteboard.pasteboardItems?.compactMap { content in
            
        }
         */
        
        Sound.currentSound.play()
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
