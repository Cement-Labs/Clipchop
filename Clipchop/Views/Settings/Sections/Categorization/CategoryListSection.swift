//
//  CategoryListSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/6/1.
//

import SwiftUI
import Defaults
import Fuse

struct CategoryListSection: View {
    @Default(.fileTypes) private var fileTypes
    @Default(.categories) private var categories
    
    @Binding var searchQuery: String
    
    @State private var chosenInsertionPopoverElement: Chosen<FileType.Category?> = .no
    
    @Environment(\.hasTitle) var hasTitle
    @Environment(\.isSearchable) var isSearchable
    @Environment(\.alternatingLayout) private var alternatingLayout
    
    private let fuse = Fuse()
    
    private var isSearching: Bool {
        isSearchable && !searchQuery.isEmpty
    }
    
    private var filteredCategories: [FileType.Category] {
        if isSearching {
            let nameIndexed = fuse.search(searchQuery, in: categories.map({ $0.name }))
                .map { categories[$0.index] }
            let contentIndexed = fuse.search(searchQuery, in: fileTypes.map({ $0.ext }))
                .flatMap { fileTypes[$0.index].categories }
                .uniqued()
            
            return nameIndexed + contentIndexed
        } else {
            return categories
        }
    }
    
    var body: some View {
        Section {
            FormSectionListContainer {
                NavigationStack {
                    List {
                        ForEach(filteredCategories) { category in
                            NavigationLink {
                                
                            } label: {
                                VStack {
                                    FormNavigationLinkLabel {
                                        Text(category.name)
                                            .badge(category.fileExts.count)
                                    }
                                    
                                    if !category.fileExts.isEmpty {
                                        WrappingHStack(models: category.fileExts, direction: .trailing) { ext in
                                            TagView(style: .quinary) {
                                                Text(ext)
                                                    .monospaced()
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
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
                    .if(!alternatingLayout) { view in
                        view.searchable(text: $searchQuery)
                    }
                }
                .toolbar {
                    if alternatingLayout {
                        ToolbarItemGroup {
                            Text("Categories")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    ToolbarItemGroup {
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
        } header: {
            if hasTitle {
                Text("Categories")
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
