//
//  ClipboardEditModel.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import CoreData
import AppKit

final class ClipboardEditModel {
    @Published var item: ClipboardHistory
    
    static let shared = ClipboardEditModel(provider: .shared)
    private let context: NSManagedObjectContext
    
    init(provider: ClipboardDataProvider, item: ClipboardHistory? = nil) {
        self.context = provider.newContext
        if let item {
            self.item = item
        } else {
            self.item = .init(context: self.context)
        }
    }
    
    func deleteAll() throws {
        let historyFetchRequest = ClipboardHistory.fetchRequest()
        let contentFetchRequest = ClipboardContent.fetchRequest()
    }
}
