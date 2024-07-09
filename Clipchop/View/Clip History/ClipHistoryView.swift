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
        
    @Environment(\.managedObjectContext) private var context
    
    @StateObject private var apps = InstalledApps()
    
    @Namespace private var animationNamespace
    
    // ClipHistoryView
    @State private var isExpanded = false
    @State private var viewState: ViewState = .collapsed
    
    // CollapsedPages
    @State private var scrollPadding: CGFloat = 12
    @State private var initialScrollPadding: CGFloat = 12
    @State private var movethebutton = false
    
    // ExpandedPages
    @State var searchText: String = ""
    @State var isSearchVisible: Bool = false
    @State var selectedTab: String = "All Types"
    @State var searchResults: [Search.SearchResult] = []
    
    private let search = Search()
    private let controller = ClipHistoryPanelController()
    private let clipboardModelEditor = ClipboardModelEditor(provider: .shared)
    
    enum ViewState {
        case expanded
        case collapsed
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
                                items: items,
                                animationNamespace: animationNamespace,
                                apps: apps,
                                undo: undo,
                                redo: redo, 
                                searchText: $searchText,
                                selectedTab: $selectedTab,
                                isSearchVisible: $isSearchVisible
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
                    searchText = ""
                    selectedTab = "All Types"
                    isSearchVisible = false
                    movethebutton = false
                }
            }
        }
    }
    
    // MARK: - ViewBuilder
    
    @ViewBuilder
    private func clip(@ViewBuilder content: @escaping () -> some View) -> some View {
        content()
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
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
