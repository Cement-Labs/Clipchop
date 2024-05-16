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
        self.changeCount = ClipboardHistorya.pasteboard.changeCount
        
        super.init()
    }
    
    // MARK: - Clipboard Change
    
    /*
    private func isNew(content: Data?) -> Bool {
        guard let content else { return false }
    }
     */
}
