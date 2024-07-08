//
//  ExpandedPages.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/7.
//

import SwiftUI

struct ExpandedPages: View {
    @Binding var selectedTab: String
    @Binding var filteredItems: [ClipboardHistory]
    
    var filteredCategories: [FileCategory]
    var animationNamespace: Namespace.ID
    var searchBar: () -> AnyView
    var tagBar: () -> AnyView
    var apps: InstalledApps
    var undo: () -> Void
    var redo: () -> Void
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    if selectedTab == "All Types" {
                        if !filteredItems.isEmpty {
                            ScrollView(.vertical, showsIndicators: false) {
                                renderSection(items: Array(filteredItems))
                            }
                        } else {
                            EmptyStatePages()
                        }
                    } else if selectedTab == "Pinned" {
                        let pinnedItems = filteredItems.filter { $0.pin }
                        if !pinnedItems.isEmpty {
                            ScrollView(.vertical, showsIndicators: false) {
                                renderSection(items: pinnedItems)
                            }
                        } else {
                            EmptyStatePages()
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
                                    EmptyStatePages()
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
}
