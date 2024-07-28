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
    
    @State private var isInEditMode = false
    @State private var categorySearchText: String = ""
    @State private var fileTypeSearchText: String = ""
    @State private var isPopoverPresented = false
    @State private var contentType: ContentType = .category
    @State private var input: String = ""
    @State private var isRenaming: FileCategory?
    @State private var newName = ""
    @State private var eventMonitor: Any?
    @State private var showingAlert = false
    
    var filteredCategories: [FileCategory] {
        let filtered = categorySearchText.isEmpty ? categories : categories.filter { $0.name.localizedCaseInsensitiveContains(categorySearchText) }
        return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
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
                                Section(header: HStack {
                                    if isRenaming?.id == category.id {
                                        TextField("",text: $newName, onCommit: {
                                            renameCategory(category, newName: newName)
                                            isRenaming = nil
                                        })
                                        .textFieldStyle(.roundedBorder)
                                    } else {
                                        Text(category.name)
                                    }
                                    Spacer()
                                    Button(action: {
                                        isRenaming = category
                                        newName = category.name
                                    }) {
                                        Image(systemName: "pencil")
                                    }
                                    .padding(.trailing, 10)
                                    .buttonStyle(.borderless)
                                    Button(action: {
                                        removeCategory(category)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.borderless)
                                }) {
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
            ToolbarItemGroup(placement: .automatic) {
                Button {
                    showingAlert = true
                } label: {
                    HStack{
                        Image(systemSymbol: .arrowClockwiseCircle)
                        Text("Reset")
                    }
                    .frame(minWidth: 34)
                }
                .controlSize(.extraLarge)
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Reset Categorization."),
                        message: Text("This action will irreversibly reset all file types and file classifications."),
                        primaryButton: .destructive(Text("Reset")) {
                            Defaults[.categories] = Defaults.Keys.categories.defaultValue
                            Defaults[.allTypes] = Defaults.Keys.allTypes.defaultValue
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                Button {
                    isPopoverPresented = true
                } label: {
                    HStack {
                        Image(systemSymbol: .plus)
                        Text("Add")
                    }
                    .frame(minWidth: 34)
                    
                }
                .controlSize(.extraLarge)
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
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { event in
                if event.modifierFlags.contains(.option) {
                    withAnimation {
                        isInEditMode = true
                    }
                } else {
                    withAnimation {
                        isInEditMode = false
                    }
                }
                return event
            }
        }
        .onDisappear {
            if let monitor = eventMonitor {
                NSEvent.removeMonitor(monitor)
                eventMonitor = nil
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
    
    private func renameCategory(_ category: FileCategory, newName: String) {
        if let index = categories.firstIndex(of: category) {
            categories[index].name = newName
            Defaults[.categories] = categories
        }
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
