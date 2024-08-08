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
    
    let clipHistorySearch = ClipHistorySearch()
    
    var items: FetchedResults<ClipboardHistory>
    var animationNamespace: Namespace.ID
    
    var apps: InstalledApps
    var undo: () -> Void
    var redo: () -> Void
    
    @Default(.keySwitcher) var keySwitcher
    
    @State private var searchResults: [ClipHistorySearch.SearchResult] = []
    @State private var filteredTags: [FileCategory] = []
    @State private var selectedIndex: Int? = nil
    @State private var eventLeft: Any?
    @State private var eventRight: Any?
    @State private var isOnHover: Bool = false
    @State private var shouldScroll: Bool = false
    
    @Binding var searchText: String
    @Binding var selectedTab: String
    @Binding var isSearchVisible: Bool
    
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
        ZStack {
            
            Button("selectNextItem") {
                selectNextItem()
            }
            .opacity(0)
            .allowsHitTesting(false)
            .buttonStyle(.borderless)
            .frame(width: 0, height: 0)
            .keyboardShortcut(.tab, modifiers: keySwitcher.switchereventModifier)
            
            Button("selectPreviousItem1") {
                selectPreviousItem()
            }
            .opacity(0)
            .allowsHitTesting(false)
            .buttonStyle(.borderless)
            .frame(width: 0, height: 0)
            .keyboardShortcut("`", modifiers: keySwitcher.switchereventModifier)
            
            Button("selectPreviousItem2") {
                selectPreviousItem()
            }
            .opacity(0)
            .allowsHitTesting(false)
            .buttonStyle(.borderless)
            .frame(width: 0, height: 0)
            .keyboardShortcut("·", modifiers: keySwitcher.switchereventModifier)
            
            Button("esc") {
                selectedIndex = nil
            }
            .opacity(0)
            .allowsHitTesting(false)
            .buttonStyle(.borderless)
            .frame(width: 0, height: 0)
            .keyboardShortcut(.escape, modifiers: keySwitcher.switchereventModifier)
            
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
        .onAppear {
            setupEventMonitors()
        }
        .onDisappear {
            cleanupEventMonitors()
        }
        .onReceive(.panelDidClose) { _ in
            selectedIndex = nil
        }
    }
    
    // MARK: - Expanded ViewBuilder
    
    @ViewBuilder
    private func renderSection(items: [ClipboardHistory]) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Defaults[.displayMore] ? 16 : 12) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        if Defaults[.hideTag] {
                            CardPreviewView_2(
                                item: item,
                                isSelected: isSelectedBinding(for: index),
                                keyboardShortcut: getKeyboardShortcut(for: index)
                            )
                            .id(index)
                            .environmentObject(apps)
                            .applyMatchedGeometryEffect(if: index < 6, id: item.id, namespace: animationNamespace)
                            .onHover { isOver in
                                isOnHover = isOver
                            }
                        } else {
                            CardPreviewView(
                                item: item,
                                isSelected: isSelectedBinding(for: index),
                                keyboardShortcut: getKeyboardShortcut(for: index)
                            )
                            .id(index)
                            .environmentObject(apps)
                            .applyMatchedGeometryEffect(if: index < 6, id: item.id, namespace: animationNamespace)
                            .onHover { isOver in
                                isOnHover = isOver
                            }
                        }
                    }
                }
                .padding(.horizontal, Defaults[.displayMore] ? 16 : 12)
            }
            .frame(width: Defaults[.displayMore] ? 700 : 500)
            .onChange(of: selectedIndex) { new, _ in
                if !isOnHover {
                    shouldScroll.toggle()
                }
            }
            .onChange(of: shouldScroll) { _, _ in
                if let newIndex = selectedIndex {
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .trailing)
                    }
                    shouldScroll = false
                }
            }
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
                    ForEach(filteredTags) { category in
                        TabButton(title: category.name, selectedTab: $selectedTab)
                    }
                }
            }
        }
        .onAppear(perform: setupTags)
        .frame(width: isSearchVisible ? 0 : Defaults[.displayMore] ? 622 : 425, height: 30)
        .cornerRadius(25)
    }
    
    private func setupEventMonitors() {
        eventRight = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            if event.type == .keyDown && event.keyCode == 123 {
                selectPreviousItem2()
                return nil
            }
            return event
        }

        eventLeft = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            if event.type == .keyDown && event.keyCode == 124 {
                selectNextItem2()
                return nil
            }
            return event
        }
    }
    
    private func cleanupEventMonitors() {
//         Remove event monitors to avoid leaks
        if let monitor = eventRight {
            NSEvent.removeMonitor(monitor)
            eventRight = nil
        }
        if let monitor = eventLeft {
            NSEvent.removeMonitor(monitor)
            eventLeft = nil
        }
    }
    
    private func isSelectedBinding(for index: Int) -> Binding<Bool> {
        Binding(
            get: { self.selectedIndex == index },
            set: { isSelected in
                if isSelected {
                    self.selectedIndex = index
                } else if self.selectedIndex == index {
                    self.selectedIndex = nil
                }
            }
        )
    }
    
    private func getKeyboardShortcut(for index: Int) -> String {
        guard index < 9 else { return "none" }
        return String(index + 1)
    }
    
    
    private func selectItem(at index: Int) {
        if index >= 0 && index < items.count {
            selectedIndex = index
        }
    }
    
    
    private func selectPreviousItem() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let previousIndex = (currentIndex - 1 + 5) % 5
            let actualIndex = min(previousIndex, items.count - 1)
            selectItem(at: actualIndex)
        }
    }
    
    private func selectNextItem() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let nextIndex = (currentIndex + 1) % 5
            let actualIndex = min(nextIndex, items.count - 1)
            selectItem(at: actualIndex)
        }
    }
    
    private func selectPreviousItem2() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let previousIndex = currentIndex - 1
            let actualIndex = max(previousIndex, 0)
            selectItem(at: actualIndex)
        }
    }

    private func selectNextItem2() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let nextIndex = currentIndex + 1
            let actualIndex = min(nextIndex, items.count - 1)
            selectItem(at: actualIndex)
        }
    }
    
    private func setupTags() {
        let filtered = Defaults[.categories].filter { category in
            let categoryItems = items.filter { item in
                if let contentsSet = item.contents as? Set<ClipboardContent> {
                    let contentsArray = Array(contentsSet)
                    let formatter = Formatter(contents: contentsArray)
                    return category.types.contains { $0.caseInsensitiveEquals(formatter.title ?? "") }
                } else {
                    return false
                }
            }
            return !categoryItems.isEmpty
        }
        filteredTags = filtered.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
}

extension String {
    func caseInsensitiveEquals(_ other: String) -> Bool {
        return self.lowercased() == other.lowercased()
    }
}
