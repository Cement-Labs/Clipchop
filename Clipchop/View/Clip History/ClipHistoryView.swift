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
    @State var searchResults: [ClipHistorySearch.SearchResult] = []
    
    private let search = ClipHistorySearch()
    private let controller = ClipHistoryPanelController()
    private let clipboardModelEditor = ClipboardModelEditor(provider: .shared)
    
    enum ViewState {
        case expanded
        case collapsed
    }
    
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
                        Group {
                            if viewState == .collapsed {
                                AnyView(CollapsedPages(
                                    items: items,
                                    animationNamespace: animationNamespace,
                                    scrollPadding: $scrollPadding,
                                    initialScrollPadding: $initialScrollPadding,
                                    movethebutton: $movethebutton,
                                    clipboardModelEditor: clipboardModelEditor,
                                    apps: apps,
                                    undo: undo,
                                    redo: redo
                                ).id("collapsed"))
                            } else {
                                AnyView(ExpandedPages(
                                    items: items,
                                    animationNamespace: animationNamespace,
                                    apps: apps,
                                    undo: undo,
                                    redo: redo,
                                    searchText: $searchText,
                                    selectedTab: $selectedTab,
                                    isSearchVisible: $isSearchVisible
                                ).id("expanded"))
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .preferredColorScheme(preferredColorScheme.colorScheme)
        .animation(.easeInOut, value: preferredColorScheme)
        .onReceive(NotificationCenter.default.publisher(for: .didChangeExpansionState)) { notification in
            if let userInfo = notification.userInfo, let isExpanded = userInfo["isExpanded"] as? Bool {
                searchText = ""
                withAnimation(.default) {
                    isSearchVisible = false
                    selectedTab = NSLocalizedString("All Types", comment: "All Types")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.default) {
                        viewState = isExpanded ? .expanded : .collapsed
                    }
                }
            }
        }
        .onChange(of: searchText) { oldValue, newValue in
            controller.resetCloseTimer()
        }
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
