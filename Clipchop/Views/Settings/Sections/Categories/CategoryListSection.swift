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

    @State var isInEditMode = false
    @State var isPopoverPresented = false
    @State var contentType: ContentType = .category
    @State var input: String = ""

    var canSubmitInput: Bool {
        switch contentType {
        case .category:
            !input.isEmpty
        case .fileType:
            !input.isEmpty && Defaults.isValidFileTypeInput(input) && Defaults.isNewFileTypeInput(input)
        }
    }
    
    var body: some View {
        FileTypeListView(types: $allTypes, isInEditMode: $isInEditMode) { indexSet in
            allTypes.remove(atOffsets: indexSet)
        } onSingleDelete: { type in
            Defaults.removeFileTypeFromAll(type)
        } label: {  
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
        }
        
        .onAppear {
            // Hold option to enable edit mode
            NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                withAnimation(.default.speed(2)) {
                    isInEditMode = event.modifierFlags.contains(.option)
                }
                return event
            }
        }

        ForEach($categories) { category in
            FileTypeListView(types: category.types, isInEditMode: $isInEditMode, onDropOf: [.text], onDropDelegate: FileTypeDropDelegate(
                destinationCategory: category,
                categories: $categories,
                allTypes: $allTypes
            )) { indexSet in
                category.types.wrappedValue.remove(atOffsets: indexSet)
            } label: {
                HStack {
                    TextField("", text: category.name, prompt: Text(category.id.uuidString).monospaced())
                        .textFieldStyle(.plain)
                        .ignoresSafeArea()
                        .font(.headline)
                        .padding(.leading, -8)
                        .padding(.trailing, 8)
                    
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
