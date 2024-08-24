//
//  ExpandedPages.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/7.
//

import SwiftUI
import Defaults
import Fuse
import CoreData
import SFSafeSymbols

struct ExpandedPages: View {
    
    let clipHistorySearch = ClipHistorySearch()
    let folderManager = FolderManager()
    
    @FetchRequest(fetchRequest: ClipboardHistory.all(), animation: .snappy(duration: 0.75)) private var items
    @Environment(\.managedObjectContext) private var context
    
    var animationNamespace: Namespace.ID
    
    var apps: InstalledApps
    var undo: () -> Void
    var redo: () -> Void
    
    @Default(.keySwitcher) var keySwitcher
    
    @State private var searchResults: [ClipHistorySearch.SearchResult] = []
    @State private var filteredTags: [FileCategory] = []
    @State private var selectedIndex: Int? = nil
    
    @State private var eventScroll: Any?
    @State private var showBackToTop: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var proxy: ScrollViewProxy?
    
    @Binding var searchText: String
    @Binding var selectedTab: String
    @Binding var isSearchVisible: Bool
    
    @State private var isTagBarVisible: Bool = true
    @State private var isFolderBarVisible: Bool = false
    
    var filteredCategories: [FileCategory] {
        return Defaults[.categories].sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var filteredFolders: [Folder] {
        return Defaults[.folders].sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
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
            
            Button("selectPreviousItem2") {
                selectPreviousItem2()
            }
            .opacity(0)
            .allowsHitTesting(false)
            .buttonStyle(.borderless)
            .frame(width: 0, height: 0)
            .keyboardShortcut(.leftArrow, modifiers: [])
            
            Button("selectPreviousItem2") {
                selectNextItem2()
            }
            .opacity(0)
            .allowsHitTesting(false)
            .buttonStyle(.borderless)
            .frame(width: 0, height: 0)
            .keyboardShortcut(.rightArrow, modifiers: [])
            
            Button("selectPreviousTab") {
                switchToPreviousTab()
            }
            .opacity(0)
            .allowsHitTesting(false)
            .buttonStyle(.borderless)
            .frame(width: 0, height: 0)
            .keyboardShortcut(.leftArrow, modifiers: .command)
            
            Button("selectNextTab") {
                switchToNextTab()
            }
            .opacity(0)
            .allowsHitTesting(false)
            .buttonStyle(.borderless)
            .frame(width: 0, height: 0)
            .keyboardShortcut(.rightArrow, modifiers: .command)
            
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
                    ForEach(folderManager.allFolders(), id: \.self) { folderName in
                        if selectedTab == folderName {
                            let folderItems = filteredItems.filter { item in
                                return folderManager.items(inFolder: folderName)?.contains(item.id!) ?? false
                            }
                            
                            if !folderItems.isEmpty {
                                renderSection(items: folderItems)
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
            .overlay(
                HStack(spacing: 7.5) {
                    tagBar()
                    folderBar()
                    searchBar()
                }
                .padding([.horizontal, .top], 15),
                alignment: .top
            )
        }
        .onAppear {
//            setupEventMonitors()
        }
        .onDisappear {
//            cleanupEventMonitors()
        }
        .onReceive(.panelDidClose) { _ in
            selectedIndex = nil
            scrollOffset = 0
            if let proxy = proxy {
                proxy.scrollTo(Int(scrollOffset), anchor: .center)
            }
        }
        .onReceive(.panelDidLogout) { _ in
//            cleanupEventMonitors()
        }
    }
    
    // MARK: - Expanded ViewBuilder
    
    @ViewBuilder
    private func renderSection(items: [ClipboardHistory]) -> some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Defaults[.displayMore] ? 16 : 12) {
                    ForEach(Array(items.enumerated().filter { (($0.element.contents) != nil) }), id: \.element.id) { index, item in
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
                .background(
                    GeometryReader { geometry -> Color in
                        DispatchQueue.main.async {
                            withAnimation {
                                let offsetX = geometry.frame(in: .named("scroll")).minX
                                showBackToTop = offsetX < CGFloat(-9) * (Defaults[.displayMore] ? 16 : 12)
                            }
                        }
                        return Color.clear
                    }
                )
            }
            .overlay(backToTop().padding([.bottom, .trailing], 10).shadow(radius: 15), alignment: .bottomTrailing)
            .frame(width: Defaults[.displayMore] ? 700 : 500)
            .onAppear {
                proxy = scrollViewProxy
            }
        }
    }
    
    @ViewBuilder
    private func backToTop() -> some View {
        ZStack {
            if showBackToTop {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.thinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                    Button(action: {
                        withAnimation {
                            if let proxy = proxy {
                                withAnimation {
                                    proxy.scrollTo(Int(0), anchor: .center)
                                }
                            }
                        }
                        selectedIndex = nil
                    }) {
                        Image(systemSymbol: .chevronLeft)
                            .frame(width: 10, height: 10)
                            .padding(5)
                    }
                    .keyboardShortcut(.tab, modifiers: [])
                    .buttonStyle(.borderless)
                }
            }
        }
        .frame(width: 30, height: 30)
        .cornerRadius(25)
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
                    .disabled(!isSearchVisible)
                    .padding([.leading, .horizontal], 15)
                    .frame(width: Defaults[.displayMore] ? 623 : 365, height: 30)
                }
                Button(action: {
                    withAnimation(.smooth(duration: 0.6)) {
                        isSearchVisible = true
                        isTagBarVisible = false
                        isFolderBarVisible = false
                    }
                    if !isSearchVisible {
                        searchText = ""
                        searchResults = []
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
        .frame(width: isSearchVisible ? (Defaults[.displayMore] ? 668 : 395) : 30, height: 30)
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
            if isTagBarVisible {
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            TabButton(title: NSLocalizedString("All Types", comment: "All Types"), selectedTab: $selectedTab)
                                .id("All Types")
                            TabButton(title: NSLocalizedString("Pinned", comment: "Pinned"), selectedTab: $selectedTab)
                                .id("Pinned")
                            ForEach(filteredTags) { category in
                                TabButton(title: category.name, selectedTab: $selectedTab)
                                    .id(category.name)
                            }
                        }
                    }
                    .onChange(of: selectedTab) { newValue, _ in
                        scrollProxy.scrollTo(newValue, anchor: .center)
                    }
                }
            } else {
                Button(action: {
                    withAnimation(.smooth(duration: 0.6)) {
                        isTagBarVisible = true
                        isSearchVisible = false
                        isFolderBarVisible = false
                        selectedTab = NSLocalizedString("All Types", comment: "All Types")
                    }
                }) {
                    Image(systemSymbol: .tag)
                        .resizable()
                        .frame(width: 10, height: 10)
                        .padding(5)
                }
                .keyboardShortcut("a", modifiers: .command)
                .frame(width: 30, height: 30)
                .buttonStyle(.borderless)
            }
        }
        .onAppear(perform: setupTags)
        .frame(width: isTagBarVisible ? (Defaults[.displayMore] ? 622 : 395) : 30, height: 30)
        .cornerRadius(25)
    }
    
    @ViewBuilder
    private func folderBar() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
            if isFolderBarVisible {
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(filteredFolders) { folder in
                                TabButton(title: folder.name, selectedTab: $selectedTab)
                                    .id(folder.name)
                            }
                        }
                    }
                    .onChange(of: selectedTab) { newValue, _ in
                        scrollProxy.scrollTo(newValue, anchor: .center)
                    }
                }
            } else {
                Button(action: {
                    withAnimation(.smooth(duration: 0.6)) {
                        isFolderBarVisible = true
                        isSearchVisible = false
                        isTagBarVisible = false
                        selectedTab = (filteredFolders.first?.name) ?? NSLocalizedString("All Types", comment: "All Types")
                    }
                }) {
                    Image(systemSymbol: .folder)
                        .resizable()
                        .frame(width: 10, height: 10)
                        .padding(5)
                }
                .keyboardShortcut("f", modifiers: .command)
                .frame(width: 30, height: 30)
                .buttonStyle(.borderless)
            }
        }
        .frame(width: isFolderBarVisible ? (Defaults[.displayMore] ? 622 : 395) : 30, height: 30)
        .cornerRadius(25)
    }
    
    private func switchToPreviousTab() {
        guard let currentIndex = getCurrentTabIndex(), currentIndex > 0 else {
            return
        }
        let previousIndex = currentIndex - 1
        withAnimation {
            selectedTab = allTabs[previousIndex]
        }
    }

    private func switchToNextTab() {
        guard let currentIndex = getCurrentTabIndex(), currentIndex < allTabs.count - 1 else {
            return
        }
        let nextIndex = currentIndex + 1
        withAnimation {
            selectedTab = allTabs[nextIndex]
        }
        
    }
    
    private func getCurrentTabIndex() -> Int? {
        return allTabs.firstIndex(of: selectedTab)
    }
    
    private var allTabs: [String] {
        if isTagBarVisible {
            return [NSLocalizedString("All Types", comment: "All Types"), NSLocalizedString("Pinned", comment: "Pinned")] + filteredTags.map { $0.name }
        } else {
            return filteredFolders.map { $0.name }
        }
    }
    
    private func setupEventMonitors() {
        eventScroll = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
            let deltaY = -event.scrollingDeltaY
            
            let horizontalScrollAmount = deltaY / 5.0
            
            guard abs(horizontalScrollAmount) > 0.5 else { return event }
            
            let itemWidth: CGFloat = Defaults[.displayMore] ? 112 : 80
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
                    proxy.scrollTo(newIndex, anchor: .trailing)
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
                    proxy.scrollTo(newIndex, anchor: .trailing)
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
