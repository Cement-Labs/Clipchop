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
