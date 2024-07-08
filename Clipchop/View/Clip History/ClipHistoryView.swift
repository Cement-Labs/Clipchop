//
//  ClipHistoryView.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import SwiftUI
import CoreData
import Defaults
import SFSafeSymbols

struct ClipHistoryView: View {
    
    @FetchRequest(fetchRequest: ClipboardHistory.all(), animation: .snappy(duration: 0.75)) private var items
        
    @Environment(\.managedObjectContext) private var context
    
    @StateObject private var apps = InstalledApps()
    
    @Namespace private var animationNamespace
    
    @State private var isExpanded = false
    @State private var viewState: ViewState = .collapsed
    
    @State private var scrollPadding: CGFloat = 12
    @State private var initialScrollPadding: CGFloat = 12
    @State private var movethebutton = false
    @State private var selectedTab: String = "All Types"
    
    @State private var searchText: String = ""
    @State private var isSearchVisible: Bool = false
    @State private var filteredItems: [ClipboardHistory] = []
    
    private let controller = ClipHistoryPanelController()
    private let clipboardModelEditor = ClipboardModelEditor(provider: .shared)
    
    enum ViewState {
        case expanded
        case collapsed
    }
    var filteredCategories: [FileCategory] {
        return Defaults[.categories].sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
        
    var body: some View {
        clip {
            ZStack {
                Button(action: undo) { }
                .opacity(0)
                .allowsHitTesting(false)
                .buttonStyle(.borderless)
                .frame(width: 0, height: 0)
                .keyboardShortcut("z", modifiers: .command)
                Button(action: redo) { }
                .opacity(0)
                .allowsHitTesting(false)
                .buttonStyle(.borderless)
                .frame(width: 0, height: 0)
                .keyboardShortcut("z", modifiers: [.command, .shift])
                clip {
                    VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                }
                VStack {
                    if items.isEmpty {
                        EmptyStatePages()
                    } else {
                        switch viewState {
                        case .collapsed:
                            CollapsedPages(
                                items: items,
                                animationNamespace: animationNamespace,
                                scrollPadding: $scrollPadding,
                                initialScrollPadding: $initialScrollPadding,
                                movethebutton: $movethebutton,
                                clipboardModelEditor: clipboardModelEditor,
                                apps: apps,
                                undo: undo,
                                redo: redo
                            )
                        case .expanded:
                            ExpandedPages(
                                selectedTab: $selectedTab,
                                filteredItems: $filteredItems,
                                filteredCategories: filteredCategories,
                                animationNamespace: animationNamespace,
                                searchBar: {AnyView(searchBar())},
                                tagBar: {AnyView(tagBar())},
                                apps: apps,
                                undo: undo,
                                redo: redo
                            )
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onReceive(NotificationCenter.default.publisher(for: .didChangeExpansionState)) { notification in
            if let userInfo = notification.userInfo, let isExpanded = userInfo["isExpanded"] as? Bool {
                withAnimation(.default) {
                    viewState = isExpanded ? .expanded : .collapsed
                    selectedTab = "All Types"
                    self.isSearchVisible = false
                    filterItems()
                }
            }
        }
        .onAppear {
            filterItems()
        }
    }
    
    // MARK: - ViewBuilder
    
    @ViewBuilder
    private func clip(@ViewBuilder content: @escaping () -> some View) -> some View {
        content()
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
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
                    TextField("Search", text: $searchText)
                        .padding([.leading, .horizontal], 15)
                        .textFieldStyle(.plain)
                        .frame(width: isSearchVisible ? 425 : 30, height: 30)
                        .onChange(of: searchText) { oldValue, newValue in
                            filterItems()
                        }
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
    
    // MARK: - ModelManager
    
    func filterItems() {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: [ClipboardHistory]
            if self.searchText.isEmpty {
                result = Array(self.items)
            } else {
                let lowercasedSearchText = self.searchText.lowercased()
                result = self.items.filter { item in
                    guard let contents = item.contents as? Set<ClipboardContent> else { return false }
                    let formatter = Formatter(contents: Array(contents))
                    let appContains = item.app?.localizedCaseInsensitiveContains(lowercasedSearchText) ?? false
                    let titleContains = formatter.title?.localizedCaseInsensitiveContains(lowercasedSearchText) ?? false
                    let contentPreviewContains = formatter.contentPreview.localizedCaseInsensitiveContains(lowercasedSearchText)
                    return appContains || titleContains || contentPreviewContains
                }
            }
            DispatchQueue.main.async {
                self.filteredItems = result
            }
        }
    }
    private func undo() {
        context.undoManager?.undo()
    }
    
    private func redo() {
        context.undoManager?.redo()
    }
}
extension String {
    func caseInsensitiveEquals(_ other: String) -> Bool {
        return self.lowercased() == other.lowercased()
    }
}

