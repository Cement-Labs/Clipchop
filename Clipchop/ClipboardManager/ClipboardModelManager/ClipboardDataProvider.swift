//
//  ClipboardDataProvider.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import CoreData

final class ClipboardDataProvider {
    
    static let shared = ClipboardDataProvider()
    
    private let persistentContainer : NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var newContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ClipboardModel")
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unale to load data! \(error)")
            }
        }
    }
}

