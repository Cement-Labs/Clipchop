//
//  ClipboardHistory.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import SwiftUI
import Defaults
import CoreData
import Algorithms
import SwiftHEXColors
import UniformTypeIdentifiers

final class ClipboardHistory: NSManagedObject, Identifiable {
    enum Class {
        case all
        
        case file
        case html
        case image
        case rtf
        case text
        
        var types: [NSPasteboard.PasteboardType] {
            switch self {
            case .all: [
                .rtf, .rtfd,
                .html,
                .string,
                .fileURL, .URL,
                .jpeg, .tiff, .png,
                .pdf,
                .universalClipboard,
                .tabularText,
                .multipleTextSelection,
                .fileContents
            ]
            case .file: [
                .fileURL
            ]
            case .html: [
                .html
            ]
            case .image: [
                .jpeg, .tiff, .png
            ]
            case .rtf: [
                .rtf, .rtfd
            ]
            case .text: [
                .string
            ]
            }
        }
        
        var typeStrings: [String] {
            types.map { $0.rawValue }
        }
    }
    
    static var source: NSRunningApplication? {
        NSWorkspace.shared.frontmostApplication
    }
    
    static var pasteboard: NSPasteboard {
        .general
    }
    
    // MARK: - Fields
    
    static let entityName = "ClipboardHistory"
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipboardHistory> {
        return .init(entityName: ClipboardHistory.entityName)
    }
    
    @NSManaged public var app: String?
    @NSManaged public var id: UUID?
    @NSManaged public var list: String?
    @NSManaged public var time: Date?
    @NSManaged public var title: String?
    @NSManaged public var contents: NSSet?
    @NSManaged public var pinned: Bool
    
    private var formatter: Formatter {
        .init(contents: getContents())
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(Date.now, forKey: "time")
        setPrimitiveValue(Self.source?.localizedName, forKey: "app")
        setPrimitiveValue(nil, forKey: "list")
        setPrimitiveValue("Untitled", forKey: "title")
        setPrimitiveValue(nil, forKey: "contents")
        setPrimitiveValue(false, forKey: "pinned")
    }
    
    convenience init(contents: [ClipboardContent]) {
        let entity = NSEntityDescription.entity(
            forEntityName: ClipboardHistory.entityName,
            in: ClipboardDataProvider.shared.viewContext
        )!
        self.init(entity: entity, insertInto: ClipboardDataProvider.shared.viewContext)
        self.id = UUID()
        self.app = ClipboardHistory.source?.localizedName
        self.time = Date.now
        self.list = "1"
        self.title = formatter.title
        self.pinned = false
        
        contents.forEach(addToContents(_:))
    }
    
    // MARK: - Functions
    
    func getContents() -> [ClipboardContent] {
        (contents?.allObjects as? [ClipboardContent]) ?? []
    }
    
    func supersedes(_ item: ClipboardHistory) -> Bool {
        item.getContents()
            .filter { content in
                content.type == NSPasteboard.PasteboardType.fromClipchop.rawValue
            }
            .allSatisfy { content in
                getContents().contains([content])
            }
    }
}

extension ClipboardHistory {
    // MARK: - Objective-C Extension
    
    @objc(addContentsObject:)
    @NSManaged public func addToContents(_ value: ClipboardContent)
    
    @objc(removeContentsObject:)
    @NSManaged public func removeFromContents(_ value: ClipboardContent)
    
    @objc(addContents:)
    @NSManaged public func addToContents(_ values: NSSet)
    
    @objc(removeContents:)
    @NSManaged public func removeFromContents(_ values: NSSet)
    
    private static var itemFetchRequsest: NSFetchRequest<ClipboardHistory> {
        .init(entityName: ClipboardHistory.entityName)
    }
    
    static func all() -> NSFetchRequest<ClipboardHistory> {
        let request = itemFetchRequsest
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ClipboardHistory.time, ascending: false)]
        return request
    }
}
