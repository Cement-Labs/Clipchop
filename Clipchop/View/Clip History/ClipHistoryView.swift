//
//  ClipHistoryView.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import SwiftUI
import CoreData
import Combine
import Defaults
import SFSafeSymbols

struct ClipHistoryView: View {
    
    @FetchRequest(fetchRequest: ClipboardHistory.all(), animation: .snappy(duration: 0.75)) private var items
    
    @Default(.preferredColorScheme) private var preferredColorScheme
        
    @Environment(\.managedObjectContext) private var context
    
    @StateObject private var apps = InstalledApps()
    
    @Namespace private var animationNamespace
    
    
    // CollapsedPages
    @State private var scrollPadding: CGFloat = 12
    @State private var initialScrollPadding: CGFloat = 12
    @State private var movethebutton = false
    
    // ExpandedPages
    @State var searchText: String = ""
    @State var isSearchVisible: Bool = false
    @State var selectedTab: String = "All Types"
    @State var searchResults: [ClipHistorySearch.SearchResult] = []
    
    private let search = ClipHistorySearch()
    private let clipboardModelEditor = ClipboardModelEditor(provider: .shared)
    
    let controller: ClipHistoryPanelController
    
    var body: some View {
        clip {
            ZStack(alignment: .top) {
                
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
                        if controller.isExpandedforView {
                            ExpandedPages(
                                items: items,
                                animationNamespace: animationNamespace,
                                apps: apps,
                                undo: undo,
                                redo: redo,
                                searchText: $searchText,
                                selectedTab: $selectedTab,
                                isSearchVisible: $isSearchVisible
                                
                            )
                        } else {
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
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(preferredColorScheme.colorScheme)
        .onChange(of: searchText) { oldValue, newValue in
            controller.resetCloseTimer()
        }
        .onChange(of: controller.isExpandedforView) { isExpanded, _ in
            handleExpansionStateChange(isExpanded: isExpanded)
        }
    }
    
    private func handleExpansionStateChange(isExpanded: Bool) {
        withAnimation(.default) {
            isSearchVisible = false
            selectedTab = NSLocalizedString("All Types", comment: "All Types")
        }
        searchText = ""
    }
    
    // MARK: - ModelManager
    
    private func undo() {
        context.undoManager?.undo()
    }
    
    private func redo() {
        context.undoManager?.redo()
    }
    
    private func performSearch() {
        if searchText.isEmpty {
            searchResults = []
        } else {
            searchResults = search.search(string: searchText, within: Array(items))
        }
    }
}

@ViewBuilder
func clip(@ViewBuilder content: @escaping () -> some View) -> some View {
    content()
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
}
