//
//  Content.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import CoreData

final class Content: NSManagedObject {
    static let entityName = "Content"
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Content> {
        .init(entityName: Content.entityName)
    }
    
    @NSManaged public var item: History?
    @NSManaged public var type: String?
    @NSManaged public var value: Data?
    
    convenience init(type: String, value: Data?) {
        let entity = NSEntityDescription.entity(
            forEntityName: Content.entityName,
            in: ClipboardHistoryProvider.shared.viewContext
        )!
        self.init(entity: entity, insertInto: ClipboardHistoryProvider.shared.viewContext)
        
        self.type = type
        self.value = value
    }
}
