//
//  CategoryListSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/6/1.
//

import SwiftUI
import Defaults

struct CategoryListSection: View {
    @Default(.categories) private var categories
    
    @State private var chosenInsertionPopoverElement: Chosen<FileType.Category?> = .no
    @State private var searchQuery: String = ""
    
    private var isSearching: Bool {
        searchQuery.isEmpty
    }
    
    private var filteredCategories: [FileType.Category] {
        if isSearching {
            categories.filter { $0.name.lowercased() }
        } else {
            categories
        }
    }
    
    var body: some View {
        Section {
            FormSectionListContainer {
                NavigationStack {
                    List {
                        ForEach(categories) { category in
                            NavigationLink {
                                
                            } label: {
                                FormNavigationLinkLabel {
                                    Text(category.name)
                                        .badge(category.fileExts.count)
                                }
                                .contextMenu {
                                    Button("Insert") {
                                        chosenInsertionPopoverElement = .yes(category)
                                    }
                                    
                                    Button("Remove from File Types", role: .destructive) {
                                        categories.updateEach { mutableCategory in
                                            if mutableCategory == category {
                                                mutableCategory.fileExts = []
                                            }
                                        }
                                    }
                                    
                                    Button("Delete", role: .destructive) {
                                        categories.removeAll { $0 == category }
                                    }
                                }
                                
                                // Requires a non-transparent background to expand the hit testing area
                                .background(.placeholder.opacity(0.0001))
                            }
                            .padding(.vertical, 4)
                            
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button("Insert") {
                                    chosenInsertionPopoverElement = .yes(category)
                                }
                                .tint(.accentColor)
                            }
                            .popover(isPresented: .init {
                                chosenInsertionPopoverElement == .yes(category)
                            } set: { _ in
                                chosenInsertionPopoverElement = .no
                            }) {
                                newElementPopover(category: category)
                            }
                            .selectionDisabled()
                        }
                        .onMove { indexSet, destination in
                            categories.move(fromOffsets: indexSet, toOffset: destination)
                        }
                        .onDelete { indexSet in
                            categories.remove(atOffsets: indexSet)
                        }
                    }
                    .listStyle(.bordered)
                    .alternatingRowBackgrounds()
                    .searchable(text: $searchQuery, placement: .toolbar)
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
    private func newElementPopover(category: FileType.Category? = nil) -> some View {
        NewElementPopover("Category Name") { input in
            !input.isEmpty
        } onCompletion: { input in
            insertCategory(.init(name: input), after: category)
            chosenInsertionPopoverElement = .no
        }
    }
    
    private func insertCategory(_ newElement: FileType.Category, after: FileType.Category?) {
        if
            let after,
            let destination = categories.firstIndex(of: after)
        {
            categories.insert(newElement, at: categories.index(after: destination))
        } else {
            categories.append(newElement)
        }
    }
}
