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
    
    @FetchRequest(fetchRequest: ClipboardHistory.all(), animation: .snappy(duration: 0.75)) private var items
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
    @State private var eventScroll: Any?
    
    @State private var scrollOffset: CGFloat = 0
    @State private var proxy: ScrollViewProxy?
    
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
            cleanupEventMonitors()
            scrollOffset = 0
            if let proxy = proxy {
                proxy.scrollTo(Int(scrollOffset), anchor: .center)
            }
        }
        .onReceive(.panelDidOpen) { _ in
            selectedIndex = nil
            setupEventMonitors()
            scrollOffset = 0
            if let proxy = proxy {
                proxy.scrollTo(Int(scrollOffset), anchor: .center)
            }
        }
    }
    
    // MARK: - Expanded ViewBuilder
    
    @ViewBuilder
    private func renderSection(items: [ClipboardHistory]) -> some View {
        ScrollViewReader { scrollViewProxy in
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
                        } else {
                            CardPreviewView(
                                item: item,
                                isSelected: isSelectedBinding(for: index),
                                keyboardShortcut: getKeyboardShortcut(for: index)
                            )
                            .id(index)
                            .environmentObject(apps)
                            .applyMatchedGeometryEffect(if: index < 6, id: item.id, namespace: animationNamespace)
                        }
                    }
                }
                .padding(.horizontal, Defaults[.displayMore] ? 16 : 12)
            }
            .frame(width: Defaults[.displayMore] ? 700 : 500)
            .onAppear {
                proxy = scrollViewProxy
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
        
        eventScroll = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
            let deltaY = event.scrollingDeltaY
            
            let horizontalScrollAmount = deltaY / 5.0
            
            guard abs(horizontalScrollAmount) > 0.5 else { return event }

            let itemWidth: CGFloat = Defaults[.displayMore] ? 116 : 112
            let totalContentWidth = CGFloat(items.count) * itemWidth

            if let proxy = proxy {
               
                withAnimation {
                    scrollOffset = max(0, min(scrollOffset + horizontalScrollAmount, totalContentWidth))
                    proxy.scrollTo(Int(scrollOffset), anchor: .center)
                }
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
        if let monitor = eventScroll {
            NSEvent.removeMonitor(monitor)
            eventScroll = nil
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
            let itemCount = min(items.count, 5)
            let previousIndex = (currentIndex - 1 + itemCount) % itemCount
            selectItem(at: previousIndex)
        }
    }

    private func selectNextItem() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let itemCount = min(items.count, 5)
            let nextIndex = (currentIndex + 1) % itemCount
            selectItem(at: nextIndex)
        }
    }
    
    private func selectPreviousItem2() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let itemCount = items.count
            
            if itemCount == 0 { return }
            
            let previousIndex = currentIndex > 0 ? currentIndex - 1 : 0
            selectItem(at: previousIndex)
            if let newIndex = selectedIndex, let proxy = proxy  {
                withAnimation {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }

    private func selectNextItem2() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let itemCount = items.count
            
            if itemCount == 0 { return }
            
            let nextIndex = currentIndex < itemCount - 1 ? currentIndex + 1 : itemCount - 1
            selectItem(at: nextIndex)
            if let newIndex = selectedIndex, let proxy = proxy  {
                withAnimation {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
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
