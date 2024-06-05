//
//  ClipboardHistory.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/18.
//
//

import Foundation
import SwiftData
import AppKit

@Model
final class ClipboardHistory: Equatable, Identifiable, Hashable {
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
    
    static var source: NSRunningApplication? {
        NSWorkspace.shared.frontmostApplication
    }
    
    static var pasteboard: NSPasteboard {
        .general
    }
    
    static func == (lhs: ClipboardHistory, rhs: ClipboardHistory) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Fields
    
    @Attribute(.unique)
    var id: UUID
    var app: String?
    var appId: String?
    var pinned: Bool
    var deleted: Bool
    var time: Date?
    
    @Relationship(deleteRule: .cascade) var contents: [ClipboardContent]?
    
    var formatter: Formatter {
        .init(contents: getContents())
    }
    
    public init() {
        self.id = .init()
        self.pinned = false
        self.deleted = false
        
        self.app = ClipboardHistory.source?.localizedName
        self.appId = ClipboardHistory.source?.bundleIdentifier
       
        self.time = Date.now
    }
    
    // MARK: - Functions
    
    func getContents() -> [ClipboardContent] {
        contents ?? []
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
