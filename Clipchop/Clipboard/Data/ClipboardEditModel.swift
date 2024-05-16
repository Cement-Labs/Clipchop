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
    
    func deleteAll(ignoresPinned: Bool = true) throws {
        let historyFetchRequest = ClipboardHistory.fetchRequest()
        let contentFetchRequest = ClipboardContent.fetchRequest()
        
        do {
            let histories = try context.fetch(historyFetchRequest)
            histories.forEach(context.delete(_:))
            
            let contents = try context.fetch(contentFetchRequest)
            contents.forEach(context.delete(_:))
            
            try context.save()
            print("Deleted all clipboard data.")
        } catch {
            let nsError = error as NSError
            print("Error deleting all clipboard data! \(nsError), \(nsError.userInfo)")
            
            throw nsError
        }
    }
    
    func deleteEmpty() throws {
        let fetchRequest = ClipboardHistory.fetchRequest()
        fetchRequest.predicate = .init(format: "\(ClipboardHistory.Managed.list) == nil")
        
        do {
            let histories = try context.fetch(fetchRequest)
            histories.forEach(context.delete(_:))
            
            try context.save()
            print("Deleted empty clipboard data.")
        } catch {
            let nsError = error as NSError
            print("Error deleting empty clipboard data! \(nsError), \(nsError.userInfo)")
            
            throw nsError
        }
    }
}
