//
//  FileTypeListSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/28.
//

import SwiftUI
import Defaults
import Fuse

struct FileTypeListSection: View {
    @Default(.fileTypes) private var fileTypes
    
    @Binding var searchQuery: String
    
    @State private var chosenInsertionPopoverElement: Chosen<FileType?> = .no
    
    @Environment(\.isSearchable) private var isSearchable
    
    private let fuse = Fuse()
    
    private var isSearching: Bool {
        !searchQuery.isEmpty
    }
    
    private var filteredFileTypes: [FileType] {
        if isSearching {
            fuse.search(searchQuery, in: fileTypes.map({ $0.ext }))
                .map { fileTypes[$0.index] }
        } else {
            fileTypes
        }
    }
    
    var body: some View {
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
