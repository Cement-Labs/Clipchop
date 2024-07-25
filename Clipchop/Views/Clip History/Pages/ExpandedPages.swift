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
    
    let clipHistorySearch = ClipHistorySearch()
    @State private var searchResults: [ClipHistorySearch.SearchResult] = []
    
    var filteredCategories: [FileCategory] {
        return Defaults[.categories].sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var filteredItems: [ClipboardHistory] {
        if searchText.isEmpty {
            return Array(items)
        } else {
            return clipHistorySearch.search(string: searchText, within: Array(items)).map { $0.object as! ClipboardHistory }
        }
    }
    
    var body: some View {
        VStack {
            if selectedTab == NSLocalizedString("All Types", comment: "All Types") {
                if !filteredItems.isEmpty {
                    renderSection(items: filteredItems)
                } else {
                    EmptyStatePages()
                        .padding(.vertical, 24)
                }
            } else if selectedTab == NSLocalizedString("Pinned", comment: "Pinned") {
                let pinnedItems = filteredItems.filter { $0.pin }
                if !pinnedItems.isEmpty {
                    renderSection(items: pinnedItems)
                } else {
                    EmptyStatePages()
                        .padding(.vertical, 24)
                }
            } else {
                ForEach(filteredCategories) { category in
                    if selectedTab == category.name {
                        let categoryItems = filteredItems.filter { item in
                            if let contentsSet = item.contents as? Set<ClipboardContent> {
                                let contentsArray = Array(contentsSet)
                                let formatter = Formatter(contents: contentsArray)
                                return category.types.contains { $0.caseInsensitiveEquals(formatter.title ?? "") }
                            } else {
                                return false
                            }
                        }
                        
                        if !categoryItems.isEmpty {
                            renderSection(items: categoryItems)
                        } else {
                            EmptyStatePages()
                                .padding(.vertical, 24)
                        }
                    }
                }
            }
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .overlay(searchBar().padding([.top, .trailing], 15), alignment: .topTrailing)
        .overlay(tagBar().padding([.top, .leading], 15), alignment: .topLeading)
    }
    
    // MARK: - Expanded ViewBuilder
    
    @ViewBuilder
    private func renderSection(items: [ClipboardHistory]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Defaults[.displayMore] ? 16 : 12) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    CardPreviewView(item: item, keyboardShortcut: getKeyboardShortcut(for: index))
                        .environmentObject(apps)
                        .applyMatchedGeometryEffect(if: items.firstIndex(of: item) ?? 0 < 6, id: item.id, namespace: animationNamespace)
                }
            }
            .padding(.horizontal, Defaults[.displayMore] ? 16 : 12)
        }
        .frame(width: Defaults[.displayMore] ? 700 : 500)
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
                    SearchFieldWrapper(searchText: $searchText, placeholder: NSLocalizedString("Search", comment: "Search")) { query in
                        self.searchText = query
                        self.searchResults = clipHistorySearch.search(string: query, within: Array(items))
                    }
                    .padding([.leading, .horizontal], 15)
                    .frame(width: 425, height: 30)
                }
                Button(action: {
                    withAnimation {
                        isSearchVisible.toggle()
                        if !isSearchVisible {
                            searchText = ""
                            searchResults = []
                        }
                    }
                }) {
                    Image(systemSymbol: .magnifyingglass)
                        .resizable()
                        .frame(width: 10, height: 10)
                        .padding(5)
                }
                .keyboardShortcut("s", modifiers: .command)
                .buttonStyle(.borderless)
                .offset(x: isSearchVisible ? -5 : 0)
            }
        }
        .frame(width: isSearchVisible ?  Defaults[.displayMore] ? 668 : 470 : 30, height: 30)
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
                    TabButton(title: NSLocalizedString("All Types", comment: "All Types"), selectedTab: $selectedTab)
                    TabButton(title: NSLocalizedString("Pinned", comment: "Pinned"), selectedTab: $selectedTab)
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
        .frame(width: isSearchVisible ? 0 :  Defaults[.displayMore] ? 622 : 425, height: 30)
        .cornerRadius(25)
    }
    
    private func getKeyboardShortcut(for index: Int) -> String {
        guard index < 9 else { return "none" }
        return String(index + 1)
    }
}

extension String {
    func caseInsensitiveEquals(_ other: String) -> Bool {
        return self.lowercased() == other.lowercased()
    }
}
