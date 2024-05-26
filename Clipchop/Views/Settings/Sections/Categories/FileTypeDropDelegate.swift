//
//  FileTypeDropDelegate.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import UniformTypeIdentifiers
import SwiftUI

struct FileTypeDropDelegate: DropDelegate {
    @Binding var destinationCategory: FileCategory
    @Binding var categories: [FileCategory]
    @Binding var uncategorizedTypes: [String]
    
    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [UTType.text]).first else { return false }
        
        item.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data as? Data, let fileType = String(data: data, encoding: .utf8) else { return }
                
                if destinationCategory.types.contains(fileType) {
                    return
                }
                
                destinationCategory.types.append(fileType)
            }
        }
        
        return true
    }
}
