//
//  ClipboardDataProvider.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import Foundation
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
        persistentContainer = NSPersistentContainer(name: "ClipboardData")
        
        // Autosaves
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        // Load persistent stores
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unale to load data! \(error)")
            }
        }
    }
}
