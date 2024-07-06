//
//  ClipboardHistory.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import AppKit
import CoreData

final class ClipboardHistory: NSManagedObject, Identifiable {
    enum Class {
        case all
        
        case file
        case html
        case image
        case rtf
        case text
        case url
        
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
            case .url: [
                .URL
            ]
            }
        }
        
        var typeStrings: [String] {
            types.map { $0.rawValue }
        }
    }
    
    enum Managed: String {
        case app = "app"
        case appid = "appid"
        
        case id = "id"
        case time = "time"
        
        case pin = "pin"
        case contents = "contents"
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
        return NSFetchRequest<ClipboardHistory>(entityName: ClipboardHistory.entityName)
    }
    
    @NSManaged public var app: String?
    @NSManaged public var appid: String?
    
    @NSManaged public var id: UUID?
    @NSManaged public var time: Date?
    
    @NSManaged public var pin: Bool
    @NSManaged public var contents: NSSet?
    
    
    var formatter: Formatter {
        .init(contents: getContents())
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        setPrimitiveValue(Self.source?.localizedName, forKey: Managed.app.rawValue)
        setPrimitiveValue(Self.source?.bundleIdentifier, forKey: Managed.appid.rawValue)

        setPrimitiveValue(UUID(), forKey: Managed.id.rawValue)
        setPrimitiveValue(Date.now, forKey: Managed.time.rawValue)

        setPrimitiveValue(false, forKey: Managed.pin.rawValue)
        setPrimitiveValue(nil, forKey: Managed.contents.rawValue)
    }
    
    convenience init(contents: [ClipboardContent]) {
        let entity = NSEntityDescription.entity(
            forEntityName: ClipboardHistory.entityName,
            in: ClipboardDataProvider.shared.viewContext
        )!
        self.init(entity: entity, insertInto: ClipboardDataProvider.shared.viewContext)
        
        self.app = ClipboardHistory.source?.localizedName
        self.appid = ClipboardHistory.source?.bundleIdentifier
        
        self.id = UUID()
        self.time = Date.now
        
        self.pin = false
        
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
    
    static func all() -> NSFetchRequest<ClipboardHistory> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ClipboardHistory.time, ascending: false)]
        return request
    }
}

extension ClipboardHistory {
    var isEmpty: Bool {
        return contents == nil || contents?.count == 0
    }
}
