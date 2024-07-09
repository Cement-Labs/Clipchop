//
//  ExpandedPages.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/7.
//

import SwiftUI
import Defaults
import Fuse

struct ExpandedPages: View {
    
    var items: FetchedResults<ClipboardHistory>
    var animationNamespace: Namespace.ID
    var apps: InstalledApps
    var undo: () -> Void
    var redo: () -> Void
    
    @Binding var searchText: String
    @Binding var selectedTab: String
    @Binding var isSearchVisible: Bool
    
    let search = Search()
    @State private var searchResults: [Search.SearchResult] = []
    
    var filteredCategories: [FileCategory] {
        return Defaults[.categories].sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var filteredItems: [ClipboardHistory] {
        return searchResults.map { $0.object as! ClipboardHistory }
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    if selectedTab == "All Types" {
                        if !items.isEmpty {
                            if isSearchVisible && filteredItems.isEmpty {
                                VStack(alignment: .center) {
                                    Image(systemName: "magnifyingglass.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 24)
                                    Text("Press Enter to search")
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .foregroundStyle(.blendMode(.overlay))
                                .padding(.vertical, 60)
                            } else {
                                ScrollView(.vertical, showsIndicators: false) {
                                    renderSection(items: isSearchVisible ? filteredItems : Array(items))
                                }
                            }
                        } else {
                            EmptyStatePages()
                                .padding(.vertical, 60)
                        }
                    } else if selectedTab == "Pinned" {
                        let pinnedItems = items.filter { $0.pin }
                        if !pinnedItems.isEmpty {
                            ScrollView(.vertical, showsIndicators: false) {
                                renderSection(items: pinnedItems)
                            }
                        } else {
                            EmptyStatePages()
                                .padding(.vertical, 60)
                        }
                    } else {
                        ForEach(filteredCategories) { category in
                            if selectedTab == category.name {
                                let categoryItems = items.filter { item in
                                    if let contentsSet = item.contents as? Set<ClipboardContent> {
                                        let contentsArray = Array(contentsSet)
                                        let formatter = Formatter(contents: contentsArray)
                                        return category.types.contains { $0.caseInsensitiveEquals(formatter.title ?? "") }
                                    } else {
                                        return false
                                    }
                                }
                                
                                if !categoryItems.isEmpty {
                                    ScrollView(.vertical, showsIndicators: false) {
                                        renderSection(items: categoryItems)
                                    }
                                } else {
                                    EmptyStatePages()
                                        .padding(.vertical, 60)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 60)
            }
            .overlay(searchBar().padding([.top, .trailing], 15), alignment: .topTrailing)
            .overlay(tagBar().padding([.top, .leading], 15), alignment: .topLeading)
        }
    }
    
    private func performSearch() {
        if searchText.isEmpty {
            searchResults = []
        } else {
            searchResults = search.search(string: searchText, within: Array(items))
        }
    }
}

// MARK: - Expanded ViewBuilder

extension ExpandedPages {
    
    @ViewBuilder
    private func renderSection(items: [ClipboardHistory]) -> some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(items.filter { !$0.isEmpty }) { item in
                    CardPreviewView(item: item, keyboardShortcut: "none")
                        .environmentObject(apps)
                        .matchedGeometryEffect(
                            id: item.id,
                            in: animationNamespace,
                            properties: .frame,
                            anchor: .center,
                            isSource: true
                        )
                }
            }
            .padding(.horizontal, 12)
        }
    }
    
    @ViewBuilder
    private func searchBar() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
            HStack {
                if isSearchVisible {
                    TextField("Search", text: $searchText, onCommit: performSearch)
                        .padding([.leading, .horizontal], 15)
                        .textFieldStyle(.plain)
                        .frame(width: isSearchVisible ? 425 : 30, height: 30)
                }
                Button(action: {
                    withAnimation {
                        isSearchVisible.toggle()
                        if !isSearchVisible {
                            searchText = ""
                        } else {
                            selectedTab = "All Types"
                        }
                    }
                }) {
                    Image(systemSymbol: .magnifyingglass)
                        .resizable()
                        .frame(width: 10, height: 10)
                        .padding(5)
                }
                .keyboardShortcut("s" ,modifiers: .command)
                .buttonStyle(.borderless)
                .offset(x: isSearchVisible ? -5 : 0)
            }
        }
        .frame(width: isSearchVisible ? 465 : 30, height: 30)
        .cornerRadius(25)
    }
    
    @ViewBuilder
    private func tagBar() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    TabButton(title: "All Types", selectedTab: $selectedTab)
                    TabButton(title: "Pinned", selectedTab: $selectedTab)
                    
                    ForEach(filteredCategories) { category in
                        let categoryItems = items.filter { item in
                            if let contentsSet = item.contents as? Set<ClipboardContent> {
                                let contentsArray = Array(contentsSet)
                                let formatter = Formatter(contents: contentsArray)
                                return category.types.contains { $0.caseInsensitiveEquals(formatter.title ?? "") }
                            } else {
                                return false
                            }
                        }
                        
                        if !categoryItems.isEmpty {
                            TabButton(title: category.name, selectedTab: $selectedTab)
                        }
                    }
                }
            }
        }
        .frame(width: isSearchVisible ? 0 : 425, height: 30)
        .cornerRadius(25)
    }
}

extension String {
    func caseInsensitiveEquals(_ other: String) -> Bool {
        return self.lowercased() == other.lowercased()
    }
}
