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
    
    @Environment(\.hasTitle) private var hasTitle
    @Environment(\.isSearchable) private var isSearchable
    @Environment(\.alternatingLayout) private var alternatingLayout
    
    private let fuse = Fuse()
    
    private var isSearching: Bool {
        isSearchable && !searchQuery.isEmpty
    }
    
    private var filteredCategories: Binding<[FileType.Category]> {
        .init {
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
        } set: { newValue in
            categories.updateEach { category in
                guard let newCategory = newValue.first(where: { $0 == category }) else { return }
                category.fileExts = newCategory.fileExts
            }
        }
    }
    
    var body: some View {
#if DEBUG
        Section {
            Button {
                categories = Defaults.Keys.categories.defaultValue
            } label: {
                Text("Reset Categories (Debug)")
                    .frame(maxWidth: .infinity)
            }
        }
#endif
        
        Section {
            FormSectionListContainer {
                NavigationStack {
                    List {
                        ForEach(filteredCategories) { category in
                            NavigationLink {
                                
                            } label: {
                                VStack {
                                    FormNavigationLinkLabel {
                                        Text(category.name.wrappedValue)
                                            .badge(category.fileExts.count)
                                    }
                                    
                                    if !category.fileExts.isEmpty {
                                        WrappingHStack(models: category.fileExts.wrappedValue, direction: .trailing) { ext in
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
                                        chosenInsertionPopoverElement = .yes(category.wrappedValue)
                                    }
                                    
                                    Button("Remove from File Types", role: .destructive) {
                                        category.fileExts.wrappedValue = []
                                    }
                                    
                                    Button("Delete", role: .destructive) {
                                        categories.removeAll { $0 == category.wrappedValue }
                                    }
                                }
                                .dropDestination(for: FileType.self) { items, location in
                                    guard let type = items.first else { return false }
                                    category.fileExts.wrappedValue.append(type.ext)
                                    return true
                                } isTargeted: { inDropArea in
                                    
                                }
                                
                                // Requires a non-transparent background to expand the hit testing area
                                .background(.placeholder.opacity(0.0001))
                            }
                            .padding(.vertical, 4)
                            
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button("Insert") {
                                    chosenInsertionPopoverElement = .yes(category.wrappedValue)
                                }
                                .tint(.accentColor)
                            }
                            .popover(isPresented: .init {
                                chosenInsertionPopoverElement == .yes(category.wrappedValue)
                            } set: { _ in
                                chosenInsertionPopoverElement = .no
                            }) {
                                newElementPopover(category: category.wrappedValue)
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
