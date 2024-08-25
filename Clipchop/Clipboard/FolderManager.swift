//
//  FolderManager.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/8/24.
//

import Foundation
import Defaults

class FolderManager {
    func addFolder(named folderName: String) {
        var folders = Defaults[.folders]
        if !folders.contains(where: { $0.name == folderName }) {
            let newFolder = Folder(id: UUID(), name: folderName, itemIDs: [])
            folders.append(newFolder)
            Defaults[.folders] = folders
        }
    }

    func removeFolder(named folderName: String) {
        var folders = Defaults[.folders]
        folders.removeAll { $0.name == folderName }
        Defaults[.folders] = folders
    }
    
    func renameFolder(from oldName: String, to newName: String) {
        var folders = Defaults[.folders]
        if let index = folders.firstIndex(where: { $0.name == oldName }) {
            folders[index].name = newName
            Defaults[.folders] = folders
        }
    }
    
    func addItem(_ items: [ClipboardHistory], toFolder named: String) {
        var folders = Defaults[.folders]
        if let index = folders.firstIndex(where: { $0.name == named }) {
            let itemIDs = items.compactMap { $0.id }
            folders[index].itemIDs.append(contentsOf: itemIDs)
            Defaults[.folders] = folders
        }
    }
    
    func removeItem(_ items: [ClipboardHistory], fromFolder named: String) {
        var folders = Defaults[.folders]
        if let index = folders.firstIndex(where: { $0.name == named }) {
            let itemIDs = items.compactMap { $0.id }
            folders[index].itemIDs.removeAll { itemIDs.contains($0) }
            Defaults[.folders] = folders
        }
    }
    
    func items(inFolder named: String) -> [UUID]? {
        return Defaults[.folders].first(where: { $0.name == named })?.itemIDs
    }
    
    func allFolders() -> [String] {
        return Defaults[.folders]
            .map { $0.name }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }
    
    func refreshFolders(with existingItems: [ClipboardHistory]) {
        var folders = Defaults[.folders]
        let existingItemIDs = Set(existingItems.compactMap { $0.id })
        
        for index in folders.indices {
            folders[index].itemIDs.removeAll { !existingItemIDs.contains($0) }
        }
        
        Defaults[.folders] = folders
    }
}
