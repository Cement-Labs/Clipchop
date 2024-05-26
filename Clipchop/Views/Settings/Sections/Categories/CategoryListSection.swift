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
    @Default(.categories) private var fileCategories
    @Default(.uncategorizedFileTypes) private var uncategorizedFileTypes
    
    @State private var showingAddCategorySheet = false
    @State private var showingAddFileTypeSheet = false
    @State private var newCategoryName: String = ""
    @State private var newFileExtension: String = ""
    
    var body: some View {
        VStack {
            if !uncategorizedFileTypes.isEmpty {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Uncategorized File Types")
                            .font(.headline)
                    }
                    LazyVStack {
                        List{
                            ForEach(uncategorizedFileTypes, id: \.self) { tag in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 50)
                                    Text(tag)
                                        .font(.headline)
                                        .padding()
                                }
                                .onDrag {
                                    NSItemProvider(object: tag as NSString)
                                }
                            }
                        }
                    }
                }
                .padding()
            }

            ForEach(fileCategories.keys.sorted(), id: \.self) { category in
                VStack(alignment: .leading) {
                    HStack {
                        Text(category)
                            .font(.headline)
                        Spacer()
                        Button(action: { deleteCategory(category) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    LazyVStack {
                        List {
                            ForEach(fileCategories[category] ?? [], id: \.self) { ext in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 50)
                                    Text(ext)
                                        .font(.headline)
                                        .padding()
                                }
                                .onDrag {
                                    NSItemProvider(object: ext as NSString)
                                }
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    let ext = fileCategories[category]?[index] ?? ""
                                    deleteFileExtension(category, ext)
                                }
                            }
                        }
                        .onDrop(of: [UTType.text], delegate: DropViewDelegate(destinationCategory: category, fileCategories: $fileCategories, uncategorizedFileTypes: $uncategorizedFileTypes))
                    }
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button(action: { showingAddCategorySheet = true }) {
                        Image(systemName: "folder.badge.plus")
                    }
                    Button(action: { showingAddFileTypeSheet = true }) {
                        Image(systemName: "doc.badge.plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCategorySheet) {
            VStack {
                TextField("New Category Name", text: $newCategoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: addNewCategory) {
                    Text("Add Category")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                }
                .padding()
            }
            .frame(width: 300, height: 200)
        }
        .sheet(isPresented: $showingAddFileTypeSheet) {
            VStack {
                TextField("File Extension", text: $newFileExtension)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: addNewFileType) {
                    Text("Add File Type")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                }
                .padding()
            }
            .frame(width: 300, height: 200)
        }
    }
    
    private func addNewCategory() {
        guard !newCategoryName.isEmpty else { return }
        
        var updatedCategories = fileCategories
        if updatedCategories[newCategoryName] == nil {
            updatedCategories[newCategoryName] = []
        }
        
        fileCategories = updatedCategories
        newCategoryName = ""
        showingAddCategorySheet = false
    }
    
    private func addNewFileType() {
        guard !newFileExtension.isEmpty else { return }
        
        if !uncategorizedFileTypes.contains(newFileExtension) {
            uncategorizedFileTypes.append(newFileExtension)
        }
        
        newFileExtension = ""
        showingAddFileTypeSheet = false
    }
    
    private func deleteCategory(_ category: String) {
        fileCategories.removeValue(forKey: category)
    }
    
    private func deleteFileExtension(_ category: String, _ fileExtension: String) {
        var updatedCategories = fileCategories
        updatedCategories[category]?.removeAll { $0 == fileExtension }
        if updatedCategories[category]?.isEmpty == true {
            updatedCategories.removeValue(forKey: category)
        }
        fileCategories = updatedCategories
    }
}

struct DropViewDelegate: DropDelegate {
    let destinationCategory: String
    @Binding var fileCategories: [String: [String]]
    @Binding var uncategorizedFileTypes: [String]
    
    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [UTType.text]).first else { return false }
        
        item.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data as? Data, let fileExtension = String(data: data, encoding: .utf8) else { return }
                
                // 检查是否已经存在该文件类型
                if self.fileCategories[self.destinationCategory]?.contains(fileExtension) == true {
                    return
                }
                
                // 不删除未分类的文件类型，只是复制
                if self.fileCategories[self.destinationCategory] != nil {
                    self.fileCategories[self.destinationCategory]?.append(fileExtension)
                } else {
                    self.fileCategories[self.destinationCategory] = [fileExtension]
                }
            }
        }
        
        return true
    }
}

#Preview {
    CategoryListSection()
}
