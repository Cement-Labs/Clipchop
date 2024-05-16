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
                reorder()
                
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
    
    // MARK: - Content Reorder
    
    func reorder() {
        
    }
}
