//
//  ClipboardContent.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import Foundation
import CoreData

final class ClipboardContent: NSManagedObject {
    enum Managed: String {
        case type = "type"
        case value = "value"
    }
    
    static let entityName = "ClipboardContent"
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipboardContent> {
        .init(entityName: ClipboardContent.entityName)
    }
    
    @NSManaged public var type: String?
    @NSManaged public var value: Data?
    @NSManaged public var item: ClipboardHistory?
    
    convenience init(type: String, value: Data?) {
        let entity = NSEntityDescription.entity(
            forEntityName: ClipboardContent.entityName,
            in: ClipboardDataProvider.shared.viewContext
        )!
        self.init(entity: entity, insertInto: ClipboardDataProvider.shared.viewContext)
        
        self.type = type
        self.value = value
    }
}
