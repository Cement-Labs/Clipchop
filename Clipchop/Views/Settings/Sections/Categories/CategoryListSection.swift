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
    enum ContentType {
        case category
        case fileType
    }
    
    @Default(.categories) private var categories
    @Default(.allTypes) private var allTypes
    
    @State var isPopoverPresented = false
    @State var contentType: ContentType = .category
    @State var input: String = ""

    var canSubmitInput: Bool {
        switch contentType {
        case .category:
            true
        case .fileType:
            !input.isEmpty
        }
    }
    
    var body: some View {
        FileTypeListView(types: $allTypes) {
            Text("All")
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button {
                            isPopoverPresented = true
                        } label: {
                            Image(systemSymbol: .plus)
                        }
                        .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom) {
                            VStack {
                                HStack {
                                    Group {
                                        switch contentType {
                                        case .category:
                                            TextField("Category Name", text: $input)
                                        case .fileType:
                                            TextField("File Extension", text: $input)
                                                .monospaced()
                                        }
                                    }
                                    .textFieldStyle(.plain)
                                    .padding(2)
                                    .onSubmit {
                                        submitInput()
                                    }
                                    
                                    Button {
                                        submitInput()
                                    } label: {
                                        Image(systemSymbol: canSubmitInput ? .arrowForwardCircleFill : .exclamationmarkCircleFill)
                                            .imageScale(.large)
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.borderless)
                                    .buttonBorderShape(.circle)
                                    .disabled(!canSubmitInput)
                                }
                                .padding(4)
                                
                                Picker(selection: $contentType) {
                                    Text("Category")
                                        .tag(ContentType.category)
                                    
                                    Text("File Type")
                                        .tag(ContentType.fileType)
                                } label: {
                                    EmptyView()
                                }
                                .pickerStyle(.segmented)
                                .padding(4)
                            }
                            .frame(minWidth: 225)
                            .padding()
                        }
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
                    .buttonStyle(.borderless)
                }
            }
        }
    }
    
    private func submitInput() {
        guard canSubmitInput else { return }
        
        switch contentType {
        case .category:
            addCategory(input)
        case .fileType:
            addFileType(input)
        }
        
        isPopoverPresented = false
        input = ""
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
