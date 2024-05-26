//
//  CategoryListSection.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/26.
//

import SwiftUI
import Defaults
import UniformTypeIdentifiers

struct CategoryListSection: View {
    @Default(.categories) private var categories
    @Default(.allTypes) private var allTypes
    
    @State private var isFileImporterPresented = false
    
    @State private var newCategoryName: String = ""
    @State private var newFileType: String = ""
    
    var body: some View {
        FileTypeListView("All", types: $allTypes)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    AddContentPopoverButton("Category Name", "Add Category", action: addCategory(_:)) {
                        Image(systemSymbol: .folderBadgePlus)
                    }
                    
                    AddContentPopoverButton("Extension", "Add File Type", action: addFileType(_:)) {
                        Image(systemSymbol: .docBadgePlus)
                    }
                }
            }

        ForEach($categories) { category in
            FileTypeListView(types: category.types) {
                HStack {
                    Group {
                        if let name = category.name.wrappedValue {
                            Text(name)
                        } else {
                            Text("Category \(Text(category.id.uuidString).monospaced())")
                                .foregroundStyle(.placeholder)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        removeCategory(category.wrappedValue)
                    } label: {
                        Image(systemSymbol: .trash)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private func addCategory(_ name: String) {
        /*
        guard !newCategoryName.isEmpty else { return }
        
        var updatedCategories = fileCategories
        if updatedCategories[newCategoryName] == nil {
            updatedCategories[newCategoryName] = []
        }
        
        fileCategories = updatedCategories
         */
    }
    
    private func removeCategory(_ category: FileCategory) {
        categories.removeAll { $0 == category }
    }
    
    private func addFileType(_ fileType: String) {
        /*
        guard !newFileType.isEmpty else { return }
        
        if !uncategorizedTypes.contains(newFileType) {
            uncategorizedTypes.append(newFileType)
        }
         */
    }
    
    private func removeFileType(_ category: FileCategory, _ fileType: String) {
        /*
        var updatedCategories = fileCategories
        updatedCategories[category]?.removeAll { $0 == fileExtension }
        
        if updatedCategories[category]?.isEmpty == true {
            updatedCategories.removeValue(forKey: category)
        }
        
        fileCategories = updatedCategories
         */
    }
}
