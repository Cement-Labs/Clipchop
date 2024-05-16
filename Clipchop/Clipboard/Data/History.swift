//
//  History.swift
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

final class History: NSManagedObject, Identifiable {
    enum Classification {
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
    
    static let entityName = "History"
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return .init(entityName: History.entityName)
    }
    
    @NSManaged public var app: String?
    @NSManaged public var id: UUID?
    @NSManaged public var list: String?
    @NSManaged public var time: Date?
    @NSManaged public var title: String?
    @NSManaged public var contents: NSSet?
    @NSManaged public var pinned: Bool
    
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
    
    // MARK: - Functions
    
    private func contentData(_ types: [NSPasteboard.PasteboardType]) -> Data? {
        let contents = getContents()
        let content = contents.first { content in
            types.contains(.init(content.type!))
        }
        
        return content?.value
    }
}
