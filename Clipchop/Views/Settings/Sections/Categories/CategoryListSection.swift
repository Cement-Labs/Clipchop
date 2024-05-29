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
    
    @Default(.categories) var categories
    @Default(.allTypes) var allTypes
    
    @State private var searchText: String = ""
    @State var isPopoverPresented = false
    @State var contentType: ContentType = .category
    @State var input: String = ""
    
    var filteredTypes: [String] {
        let types = searchText.isEmpty ? allTypes : allTypes.filter { $0.localizedCaseInsensitiveContains(searchText) }
        return types.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }
    
    var sortedCategories: [FileCategory] {
        return categories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var canSubmitInput: Bool {
        switch contentType {
        case .category:
            return !input.isEmpty
        case .fileType:
            return !input.isEmpty && Defaults.isValidFileTypeInput(input) && Defaults.isNewFileTypeInput(input)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                ScrollView(showsIndicators: false) {
                    Form {
                        Section(header: Text("All Types")) {
                            VStack {
                                TextField("Search", text: $searchText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.bottom, 10)
                                
                                WrappingHStack(models: filteredTypes) { type in
                                    RoundedTagView(text: type)
                                        .onDrag {
                                            NSItemProvider(object: type as NSString)
                                        }
                                }
                            }
                        }
                    }
                    .formStyle(.grouped)
                    .frame(width: geometry.size.width * 0.45)
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack {
                        ForEach(sortedCategories, id: \.self) { category in
                            Form {
                                Section(header: Text(category.name)) {
                                    WrappingHStack(models: category.types) { type in
                                        RoundedTagView(text: type)
                                    }
                                }
                            }
                            .onDrop(of: [UTType.text], delegate: DropViewDelegate(category: Binding(get: { category }, set: { _ in }), allTypes: $allTypes))
                            .formStyle(.grouped)
                        }
                    }
                }
                .frame(width: geometry.size.width * 0.55)
                .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button {
                        isPopoverPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom) {
                        VStack {
                            HStack {
                                Group {
                                    switch contentType {
                                    case .category:
                                        TextField("Category Name", text: $input)
                                            .monospaced()
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
                                    Image(systemName: canSubmitInput ? "arrow.forward.circle.fill" : "exclamationmark.circle.fill")
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
        .frame(maxWidth: .infinity, minHeight: 350, maxHeight: .infinity)
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
        Defaults[.categories].insert(.init(name: name), at: 0)
    }
    
    private func addFileType(_ fileType: String) {
        guard Defaults.isValidFileTypeInput(fileType) && Defaults.isNewFileTypeInput(fileType) else { return }
        
        allTypes.insert(Defaults.trimFileTypeInput(fileType), at: 0)
    }
    
    private func removeCategory(_ category: FileCategory) {
        categories.removeAll { $0 == category }
    }
    
    private func removeFileType(_ category: inout FileCategory, _ fileType: String) {
        category.types.removeAll { $0 == fileType }
    }
}

struct RoundedTagView: View {
    var text: String
    
    var body: some View {
        Text(text)
            .monospaced()
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        
            .background(.placeholder.opacity(0.1))
            .clipShape(.rect(cornerRadius: 12))
    }
}

struct DropViewDelegate: DropDelegate {
    @Binding var category: FileCategory
    @Binding var allTypes: [String]
    
    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [UTType.text]).first else { return false }
        
        item.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data as? Data, let type = String(data: data, encoding: .utf8) else { return }
                
                if !category.types.contains(type) {
                    category.types.append(type)
                }
            }
        }
        
        return true
    }
}
