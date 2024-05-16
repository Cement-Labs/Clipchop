//
//  Provider.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import Foundation
import CoreData

final class Provider {
    static let shared = Provider()
    
    private let persistentContainer : NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var newContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ClipboardData")
        // AutoSave ClipboardData
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        // Load ClipboardData
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unale to load store with error: \(error)")
            }
        }
    }
}
