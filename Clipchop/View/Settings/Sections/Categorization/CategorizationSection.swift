//
//  Categorization.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/6/2.
//

import SwiftUI
import Defaults
import SFSafeSymbols
import UniformTypeIdentifiers

struct CategorizationSection: View {
    
    enum ContentType {
        case category
        case fileType
    }
    
    @Default(.categories) var categories
    @Default(.allTypes) var allTypes
    
    @State var isInEditMode = false
    @State var categorySearchText: String = ""
    @State var fileTypeSearchText: String = ""
    @State var isPopoverPresented = false
    @State var contentType: ContentType = .category
    @State var input: String = ""
    
    var filteredCategories: [FileCategory] {
        if categorySearchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.name.localizedCaseInsensitiveContains(categorySearchText) }
        }
    }
    
    var groupedAndSortedTypes: [String: [String]] {
        let filteredTypes = fileTypeSearchText.isEmpty ? allTypes : allTypes.filter { $0.localizedCaseInsensitiveContains(fileTypeSearchText) }
        let grouped = Dictionary(grouping: filteredTypes) { $0.first?.uppercased() ?? "#" }
        return grouped.mapValues { $0.sorted() }
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
        HStack(spacing: 0){
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    TextField("Search File Types", text: $fileTypeSearchText)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Form {
                        ForEach(groupedAndSortedTypes.keys.sorted(), id: \.self) { key in
                            Section(header: Text(key)) {
                                withCaption {
                                    //
                                } caption: {
                                    WrappingHStack(models: groupedAndSortedTypes[key] ?? []) { type in
                                        RoundedTagView(isDeleteButtonShown: $isInEditMode, text: type, onDelete: {
                                            removeFileType(type)
                                        })
                                        .onDrag {
                                            NSItemProvider(object: type as NSString)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .formStyle(.grouped)
                    .background(.clear)
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity * 0.4)
                }
            }
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    TextField("Search Categories", text: $categorySearchText)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    VStack(spacing: -10){
                        ForEach(filteredCategories, id: \.self) { category in
                            Form{
                                Section(header: Text(category.name)) {
                                    withCaption {
                                        //
                                    } caption: {
                                        WrappingHStack(models: category.types) { type in
                                            RoundedTagView(isDeleteButtonShown: $isInEditMode, text: type, onDelete: {
                                                removeFileType(from: category, type)
                                            })
                                            .onDrag {
                                                NSItemProvider(object: type as NSString)
                                            }
                                        }
                                    }
                                }
                            }
                            .onDrop(of: [UTType.text], delegate: DropViewDelegate(category: Binding(get: {
                                category
                            }, set: { newValue in
                                if let index = categories.firstIndex(of: category) {
                                    categories[index] = newValue
                                }
                            }), allTypes: $allTypes))
                            .background(.clear)
                            .scrollContentBackground(.hidden)
                            .formStyle(.grouped)
                        }
                    }
                    .frame(maxWidth: .infinity * 0.525)
                }
            }
        }

        .padding(.horizontal)
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
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { event in
                if event.modifierFlags.contains(.option) {
                    withAnimation{
                        isInEditMode = true
                    }
                } else {
                    withAnimation{
                        isInEditMode = false
                    }
                }
                return event
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
        Defaults[.categories].insert(.init(name: name), at: 0)
    }
    
    private func addFileType(_ fileType: String) {
        guard Defaults.isValidFileTypeInput(fileType) && Defaults.isNewFileTypeInput(fileType) else { return }
        
        allTypes.insert(Defaults.trimFileTypeInput(fileType), at: 0)
    }
    
    private func removeCategory(_ category: FileCategory) {
        categories.removeAll { $0 == category }
    }
    
    private func removeFileType(from category: FileCategory, _ fileType: String) {
        if let index = categories.firstIndex(of: category) {
            categories[index].types.removeAll { $0 == fileType }
        }
    }
    
    private func removeFileType(_ fileType: String) {
        allTypes.removeAll { $0 == fileType }
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
