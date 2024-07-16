//
//  ClipboardModelEditor.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import CoreData

final class ClipboardModelEditor {
    
    @Published var item: ClipboardHistory
    
    static let shared = ClipboardModelEditor(provider: .shared)
    private let context: NSManagedObjectContext
    
    init(provider: ClipboardDataProvider, item: ClipboardHistory? = nil) {
        self.context = provider.newContext
        if let item {
            self.item = item
        } else {
            self.item = ClipboardHistory(context: self.context)
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
            log(self,"Deleted all clipboard data")
        } catch {
            let nsError = error as NSError
            log(self,"Error deleting all clipboard data! \(nsError), \(nsError.userInfo)")
            
            throw nsError
        }
    }
    
    func deleteAllExceptPinned() throws {
        let fetchRequest = NSFetchRequest<ClipboardHistory>(entityName: "ClipboardHistory")
        fetchRequest.predicate = NSPredicate(format: "pin == NO")
        do {
            let histories = try context.fetch(fetchRequest)
            for history in histories {
                context.delete(history)
            }
            try context.save()
            print("All unpinned ClipboardHistory data deleted.")
        } catch {
            let nsError = error as NSError
            print("Error deleting data: \(nsError), \(nsError.userInfo)")
            throw nsError
        }
    }
}
