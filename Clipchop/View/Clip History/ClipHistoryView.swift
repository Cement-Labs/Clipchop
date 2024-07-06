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
    @StateObject private var viewModel = ClipHistoryViewModel()
    
    @Namespace private var animationNamespace
    
    @State private var scrollPadding: CGFloat = 12
    @State private var initialScrollPadding: CGFloat = 12
    @State private var movethebutton = false
    @State private var isExpanded = false
    @State private var selectedTab: String = "All Types"
    
    @State private var searchText: String = ""
    @State private var isSearchVisible: Bool = false
    @State private var filteredItems: [ClipboardHistory] = []
    
    private let controller = ClipHistoryViewController()
    private let clipboardModelEditor = ClipboardModelEditor(provider: .shared)
    
    var filteredCategories: [FileCategory] {
        return Defaults[.categories]
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
                        VStack(alignment: .center) {
                            Image(.clipchopFill)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 24)
                            Text("No Clipboard History Available")
                        }
                        .foregroundStyle(.blendMode(.overlay))
                    } else {
                        switch viewModel.viewState {
                        case .expanded:
                            // Use filteredItems
                            expandedView()
                        case .collapsed:
                            // Use items
                            collapsedView()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onReceive(NotificationCenter.default.publisher(for: .didChangeExpansionState)) { notification in
            if let userInfo = notification.userInfo, let isExpanded = userInfo["isExpanded"] as? Bool {
                withAnimation(.default) {
                    self.viewModel.viewState = isExpanded ? .expanded : .collapsed
                    selectedTab = "All Types"
                    self.isSearchVisible = false
                    filterItems()
                    print("filterItems(onReceive)")
                }
            }
        }
        .onAppear {
            filterItems()
            print("filterItems(onAppear)")
        }
    }
    
    // MARK: - ViewBuilder
    
    @ViewBuilder
    private func clip(@ViewBuilder content: @escaping () -> some View) -> some View {
        content()
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
    
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
    private func expandedView() -> some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    if selectedTab == "All Types" {
                        if !filteredItems.isEmpty {
                            ScrollView(.vertical, showsIndicators: false) {
                                renderSection(items: Array(filteredItems))
                            }
                        } else {
                            EmptyStateView()
                        }
                    } else if selectedTab == "Pinned" {
                        let pinnedItems = filteredItems.filter { $0.pin }
                        if !pinnedItems.isEmpty {
                            ScrollView(.vertical, showsIndicators: false) {
                                renderSection(items: pinnedItems)
                            }
                        } else {
                            EmptyStateView()
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
                                    ScrollView(.vertical, showsIndicators: false) {
                                        renderSection(items: categoryItems)
                                    }
                                } else {
                                    EmptyStateView()
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
    
    @ViewBuilder
    private func collapsedView() -> some View {
        ZStack(alignment: .topLeading) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        CardPreviewView(item: item, keyboardShortcut: getKeyboardShortcut(for: index))
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
                .offset(x: scrollPadding)
                .background(GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.frame(in: .global).minX) { newValue, _ in
                            let deltaFromInitial = newValue
                            if deltaFromInitial >= 15 && !movethebutton {
                                performHapticFeedback()
                                withAnimation(.spring()) {
                                    scrollPadding = 74
                                    movethebutton = true
                                    initialScrollPadding = scrollPadding
                                }
                            } else if deltaFromInitial < -5 && movethebutton {
                                performHapticFeedback()
                                withAnimation(.spring()) {
                                    scrollPadding = 12
                                    movethebutton = false
                                    initialScrollPadding = scrollPadding
                                    
                                }
                            }
                        }
                })
                .overlay (
                    VStack {
                        VStack(spacing: 5){
                            SettingsLink {
                                ZStack(alignment: .center) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.accentColor)
                                        .frame(width: 50, height: 38)
                                    Image(systemSymbol: .gearshape)
                                }
                            }
                            .buttonStyle(.borderless)
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.red)
                                    .frame(width: 50, height: 38)
                                Image(systemSymbol: .trash)
                            }
                            .onTapGesture {
                                showAlert()
                            }
                        }
                        .frame(width: 50, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                        .animation(.spring(), value: movethebutton)
                        .offset(x: movethebutton ? 12 : -120),
                    alignment: .leading)
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
    
    private func showAlert() {
        let alert = NSAlert()
        alert.messageText = "Clear Clipboard History"
        alert.informativeText = "This action clears all your clipboard history unrestorably, including pins."
        alert.alertStyle = .warning
        
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // TODO: Delete
            try? clipboardModelEditor.deleteAll()
        }
    }
    
    private func performHapticFeedback() {
        NSHapticFeedbackManager.defaultPerformer.perform(
            NSHapticFeedbackManager.FeedbackPattern.generic,
            performanceTime: NSHapticFeedbackManager.PerformanceTime.now
        )
    }
    
    private func getKeyboardShortcut(for index: Int) -> String {
        guard index < 9 else { return "none" }
        return String(index + 1)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(.clipchopFill)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 24)
            Text("No Clipboard History Available")
        }
        .foregroundStyle(.blendMode(.overlay))
        .frame(width: 476, height: 130)
        .padding(.all, 12)
    }
}

struct TabButton: View {
    let title: String
    @Binding var selectedTab: String
    
    var body: some View {
        Button(action: {
            withAnimation(.default) {
                selectedTab = title
            }
        }) {
            Text(title)
                .padding()
                .background(selectedTab == title ? Color.accentColor : Color.clear)
                .foregroundColor(selectedTab == title ? Color.white : Color.black)
                .cornerRadius(8)
        }
        .frame(maxWidth: 250, maxHeight: 30)
        .buttonStyle(.borderless)
        .cornerRadius(25)
    }
}

extension String {
    func caseInsensitiveEquals(_ other: String) -> Bool {
        return self.lowercased() == other.lowercased()
    }
}

