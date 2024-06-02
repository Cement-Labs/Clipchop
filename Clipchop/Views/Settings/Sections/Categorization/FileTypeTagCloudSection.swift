//
//  FileTypeTagCloudSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/28.
//

import SwiftUI
import Defaults
import Fuse

struct FileTypeTagCloudSection: View {
    @Default(.fileTypes) private var fileTypes
    
    @Binding var searchQuery: String
    
    @State private var chosenInsertionPopoverElement: Chosen<FileType?> = .no
    
    @Environment(\.hasTitle) private var hasTitle
    @Environment(\.isSearchable) private var isSearchable
    @Environment(\.alternatingLayout) private var alternatingLayout
    
    private let fuse = Fuse()
    
    private var isSearching: Bool {
        isSearchable && !searchQuery.isEmpty
    }
    
    private var filteredFileTypes: [FileType] {
        if isSearching {
            fuse.search(searchQuery, in: fileTypes.map({ $0.ext }))
                .map { fileTypes[$0.index] }
        } else {
            fileTypes
        }
    }
    
    private var filteredGroupedFileTypes: [Character: [FileType]] {
        filteredFileTypes.grouped(by: { $0.ext.first ?? "?" })
    }
    
    var body: some View {
#if DEBUG
        Section {
            Button {
                fileTypes = Defaults.Keys.fileTypes.defaultValue
            } label: {
                Text("Reset File Types (Debug)")
                    .frame(maxWidth: .infinity)
            }
        }
#endif
        
        Section {
            FormSectionListContainer {
                List {
                    ForEach(filteredGroupedFileTypes.sorted(by: { $0.key < $1.key }), id: \.key) { key, types in
                        VStack {
                            Text(String(key))
                                .monospaced()
                                .badge(types.count)
                                .foregroundStyle(.accent)
                                .font(.caption)
                            
                            WrappingHStack(models: types) { type in
                                TagView(style: .quinary) {
                                    Text(type.ext)
                                        .monospaced()
                                        .foregroundStyle(.secondary)
                                }
                                .draggable(type)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.bordered)
                .alternatingRowBackgrounds()
                .searchable(text: $searchQuery)
            }
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button {
                        chosenInsertionPopoverElement = .yes(nil)
                    } label: {
                        Image(systemSymbol: .plus)
                    }
                    .popover(isPresented: .init {
                        chosenInsertionPopoverElement == .yes(nil)
                    } set: { _ in
                        chosenInsertionPopoverElement = .no
                    }) {
                        newElementPopover()
                    }
                }
                
                if alternatingLayout {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Text("File Types")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            if hasTitle {
                Text("File Types")
            }
        }
        
        /*
        Section {
            FormSectionListContainer {
                NavigationStack {
                    List {
                        ForEach(filteredFileTypes) { type in
                            NavigationLink {
                                List {
                                    ForEach(type.categories) { category in
                                        Text(category.name)
                                    }
                                }
                                .navigationTitle(type.ext.uppercased())
                                .navigationSplitViewCollapsingDisabled()
                            } label: {
                                FormNavigationLinkLabel {
                                    Text(type.ext)
                                        .monospaced()
                                        .badge(type.categories.count)
                                        .padding(.vertical, 4)
                                }
                                .contextMenu {
                                    Button("Insert") {
                                        chosenInsertionPopoverElement = .yes(type)
                                    }
                                    
                                    Button("Reset Categories", role: .destructive) {
                                        fileTypes.updateEach { mutableType in
                                            if mutableType == type {
                                                mutableType.categories = []
                                            }
                                        }
                                    }
                                    
                                    Button("Delete", role: .destructive) {
                                        fileTypes.removeAll { $0 == type }
                                    }
                                }
                                
                                // Requires a non-transparent background to expand the hit testing area
                                .background(.placeholder.opacity(0.0001))
                            }
                            .padding(.vertical, 4)
                            
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button("Insert") {
                                    chosenInsertionPopoverElement = .yes(type)
                                }
                                .tint(.accentColor)
                            }
                            .popover(isPresented: .init {
                                chosenInsertionPopoverElement == .yes(type)
                            } set: { _ in
                                chosenInsertionPopoverElement = .no
                            }) {
                                newElementPopover(type: type)
                            }
                        }
                        .onMove { indexSet, destination in
                            fileTypes.move(fromOffsets: indexSet, toOffset: destination)
                        }
                        .onDelete { indexSet in
                            fileTypes.remove(atOffsets: indexSet)
                        }
                    }
                    .listStyle(.bordered)
                    .alternatingRowBackgrounds()
                    .if(isSearchable) { view in
                        view.searchable(text: $searchQuery)
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button {
                            chosenInsertionPopoverElement = .yes(nil)
                        } label: {
                            Image(systemSymbol: .plus)
                        }
                        .popover(isPresented: .init {
                            chosenInsertionPopoverElement == .yes(nil)
                        } set: { _ in
                            chosenInsertionPopoverElement = .no
                        }) {
                            newElementPopover()
                        }
                    }
                }
            }
        }
         */
    }
    
    @ViewBuilder
    private func newElementPopover(type: FileType? = nil) -> some View {
        NewElementPopover("file extension") { input in
            FileType.isValid(input: input) && FileType.isNew(FileType.trim(input: input))
        } onCompletion: { input in
            insertFileType(.init(ext: FileType.trim(input: input)), after: type)
            chosenInsertionPopoverElement = .no
        }
        .monospaced()
    }
    
    private func insertFileType(_ newElement: FileType, after: FileType?) {
        if
            let after,
            let destination = fileTypes.firstIndex(of: after)
        {
            fileTypes.insert(newElement, at: fileTypes.index(after: destination))
        } else {
            fileTypes.append(newElement)
        }
    }
}
