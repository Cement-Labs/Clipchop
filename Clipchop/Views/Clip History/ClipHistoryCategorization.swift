//
//  Clip Categorization.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/6/2.
//
/*
import SwiftUI
import SwiftData
import SFSafeSymbols
import Defaults

struct ClipHistoryCategorization: View {
    
    @Query(sort: \ClipboardHistory.time, order: .reverse, animation: .spring(dampingFraction: 0.7)) private var items: [ClipboardHistory]
    
    @Environment(\.modelContext) var context
    @Environment(\.undoManager) private var undoManager
    
    @State private var apps = InstalledApps()
    @State private var searchText: String = ""
    @State private var isSearchVisible: Bool = false
    
    var animationNamespace: Namespace.ID
    var rotation: Double = 80
    
    var filteredCategories: [FileCategory] {
        if searchText.isEmpty {
            return Defaults[.categories]
        } else {
            return Defaults[.categories].filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var filteredItems: [ClipboardHistory] {
        items.filter { item in
            let formatter = Formatter(contents: item.contents!)
            let appDisplayName = getAppDisplayName(for: item.app)
            return searchText.isEmpty ||
                (appDisplayName?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (formatter.title?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    private func getAppDisplayName(for bundleID: String?) -> String? {
        guard let bundleID = bundleID else { return nil }
        return apps.displayName(for: bundleID)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    if !filteredItems.isEmpty {
                        GeometryReader { itemGeometry in
                            VStack(alignment: .leading) {
                                Text("All Type")
                                    .font(.title.monospaced())
                                    .padding(.leading, 16)
                                
                                ZStack(alignment: .topLeading) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: 12) {
                                            ForEach(filteredItems) { item in
                                                CardPreviewView(item: item, keyboardShortcut: "none")
                                                    .environmentObject(apps)
                                            }
                                            .offset(x: 12)
                                        }
                                    }
                                }
                                .matchedGeometryEffect(
                                    id: "clipHistory",
                                    in: animationNamespace,
                                    properties: .frame,
                                    anchor: .center,
                                    isSource: true
                                )
                            }
                            .rotation3DEffect(.init(degrees: rotation(for: itemGeometry, in: geometry)),
                                              axis: (x: 1, y: 0, z: 0),
                                              anchor: .center
                            )
                        }
                        .frame(height: 130)
                    } else {
                        EmptyStateView()
                    }
                    
                    let pinnedItems = items.filter { $0.pinned }
                    if !pinnedItems.isEmpty {
                        renderSection(title: "Pinned", items: pinnedItems, geometry: geometry)
                    }
                    
                    ForEach(filteredCategories) { category in
                        let categoryItems = items.filter { item in
                            let formatter = Formatter(contents: item.contents!)
                            return category.types.contains(formatter.title ?? "")
                        }
                        
                        if !categoryItems.isEmpty {
                            renderSection(title: category.name, items: categoryItems, geometry: geometry)
                        }
                    }
                }
                .padding(.vertical, (size.height - 130) / 2)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .overlay(
                VStack {
                    ZStack {
                        Button(action: undo) { }
                        .disabled(!(undoManager?.canUndo ?? false))
                        .opacity(0)
                        .allowsHitTesting(false)
                        .buttonStyle(.borderless)
                        .keyboardShortcut("z", modifiers: .command)
                        .frame(width: 0, height: 0)
                        Button(action: redo) { }
                        .disabled(!(undoManager?.canRedo ?? false))
                        .opacity(0)
                        .allowsHitTesting(false)
                        .buttonStyle(.borderless)
                        .keyboardShortcut("z", modifiers: [.command, .shift])
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
                                    .cornerRadius(25)
                                    .monospaced()
                                    .textFieldStyle(.plain)
                                    .frame(width: isSearchVisible ? 425 : 30, height: 30)
                            }
                            Button(action: {
                                withAnimation {
                                    isSearchVisible.toggle()
                                }
                            }) {
                                Image(systemSymbol: .magnifyingglass)
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .padding(5)
                            }
                            .buttonStyle(.borderless)
                        }
                        .offset(x: isSearchVisible ? -10 : 0)
                    }
                    .frame(width: isSearchVisible ? 465 : 30, height: 30)
                    .cornerRadius(25)
                }
                .padding([.top,.trailing], 15)
                , alignment: .topTrailing
            )
        }
    }
    
    @ViewBuilder
    private func renderSection(title: String, items: [ClipboardHistory], geometry: GeometryProxy) -> some View {
        GeometryReader { itemGeometry in
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title.monospaced())
                    .padding(.leading, 16)
                
                ZStack(alignment: .topLeading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(items) { item in
                                CardPreviewView(item: item, keyboardShortcut: "none")
                                    .environmentObject(apps)
                            }
                            .offset(x: 12)
                        }
                    }
                }
            }
            .rotation3DEffect(.init(degrees: rotation(for: itemGeometry, in: geometry)),
                              axis: (x: 1, y: 0, z: 0),
                              anchor: .center
            )
        }
        .frame(height: 130)
    }
    
    private func rotation(for itemGeometry: GeometryProxy, in containerGeometry: GeometryProxy) -> Double {
        let containerMidY = containerGeometry.frame(in: .global).midY
        let itemMidY = itemGeometry.frame(in: .global).midY
        let offset = itemMidY - containerMidY
        let progress = offset / containerGeometry.size.height
        let degree = progress * rotation
        return degree
    }
    
    private func undo() {
        undoManager?.undo()
    }
    
    private func redo() {
        undoManager?.redo()
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
*/
