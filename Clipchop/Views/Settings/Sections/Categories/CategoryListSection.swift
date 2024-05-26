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
    @Default(.uncategorizedTypes) private var uncategorizedTypes
    
    @State private var isAddCategorySheetPresented = false
    @State private var isAddFileTypeSheetPresented = false
    
    @State private var newCategoryName: String = ""
    @State private var newFileType: String = ""
    
    var body: some View {
        if !uncategorizedTypes.isEmpty {
            Section("Uncategorized Types") {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(uncategorizedTypes, id: \.self) { tag in
                            Group {
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
        }

        VStack(spacing: 0) {
            ForEach($categories) { category in
                Section {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(category.types, id: \.self) { type in
                                Group {
                                    Text(type.wrappedValue)
                                        .font(.headline)
                                        .padding()
                                }
                                .onDrag {
                                    NSItemProvider(object: type.wrappedValue as NSString)
                                }
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    deleteFileType(category.wrappedValue, category.types[index].wrappedValue)
                                }
                            }
                            .onDrop(of: [UTType.text], delegate: FileTypeDropViewDelegate(
                                destinationCategory: category,
                                categories: $categories,
                                uncategorizedTypes: $uncategorizedTypes
                            ))
                        }
                    }
                } header: {
                    HStack {
                        Group {
                            if let name = category.name.wrappedValue {
                                Text(name)
                            } else {
                                Text("Annonymous Category")
                                    .foregroundStyle(.placeholder)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            deleteCategory(category.wrappedValue)
                        } label: {
                            Image(systemSymbol: .trash)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                HStack {
                    Button {
                        isAddCategorySheetPresented = true
                    } label: {
                        Image(systemSymbol: .folderBadgePlus)
                    }
                    
                    Button {
                        isAddFileTypeSheetPresented = true
                    } label: {
                        Image(systemSymbol: .docBadgePlus)
                    }
                }
            }
        }
        
        .sheet(isPresented: $isAddCategorySheetPresented) {
            VStack {
                TextField("Category Name", text: $newCategoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button {
                    addCategory()
                } label: {
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
        .sheet(isPresented: $isAddFileTypeSheetPresented) {
            VStack {
                TextField("File Type", text: $newFileType)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button {
                    addFileType()
                } label: {
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
    
    private func addCategory() {
        /*
        guard !newCategoryName.isEmpty else { return }
        
        var updatedCategories = fileCategories
        if updatedCategories[newCategoryName] == nil {
            updatedCategories[newCategoryName] = []
        }
        
        fileCategories = updatedCategories
        newCategoryName = ""
        isAddCategorySheetPresented = false
         */
    }
    
    private func addFileType() {
        /*
        guard !newFileType.isEmpty else { return }
        
        if !uncategorizedTypes.contains(newFileType) {
            uncategorizedTypes.append(newFileType)
        }
        
        newFileType = ""
        isAddFileTypeSheetPresented = false
         */
    }
    
    private func deleteCategory(_ category: FileCategory) {
        //categories.removeValue(forKey: category)
    }
    
    private func deleteFileType(_ category: FileCategory, _ fileType: String) {
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

struct FileTypeDropViewDelegate: DropDelegate {
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
