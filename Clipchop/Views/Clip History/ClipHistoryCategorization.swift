//
//  Clip Categorization.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/6/2.
//

import SwiftUI
import SwiftData
import SFSafeSymbols
import Defaults

struct ClipHistoryCategorization: View {
    
    @Query(
        sort: \ClipboardHistory.time,
        order: .reverse,
        animation: .spring(dampingFraction: 0.7)
    ) private var items: [ClipboardHistory]
    
    @Environment(\.modelContext) var context
    
    @State private var searchText: String = ""
    @State private var isSearchVisible: Bool = false
    
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
            return searchText.isEmpty ||
                (item.app?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (formatter.title?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    if !filteredItems.isEmpty {
                        GeometryReader { itemGeometry in
                            VStack(alignment: .leading) {
                                Text("All Types")
                                    .font(.title.monospaced())
                                    .padding(.leading, 12)
                                
                                ZStack(alignment: .topLeading) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(filteredItems) { item in
                                                CardPreviewView(item: item)
                                                    .environment(\.modelContext, context)
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
                    
                    let pinnedItems = items.filter { $0.pinned }
                    if !pinnedItems.isEmpty {
                        GeometryReader { itemGeometry in
                            VStack(alignment: .leading) {
                                Text("Pinned")
                                    .font(.title.monospaced())
                                    .padding(.leading, 12)
                                
                                ZStack(alignment: .topLeading) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(pinnedItems) { item in
                                                CardPreviewView(item: item)
                                                    .environment(\.modelContext, context)
                                            }
                                        }
                                    }
                                }
                            }
                            .rotation3DEffect(.init(degrees: rotation(for: itemGeometry, in: geometry)),
                                              axis: (x: 1, y: 0, z: 0),
                                              anchor: .center
                            )
                        }
                        .offset(x: 12)
                        .frame(height: 130)
                    }
                    
                    ForEach(filteredCategories) { category in
                        Group {
                            let filteredItems = items.filter { item in
                                let formatter = Formatter(contents: item.contents!)
                                return category.types.contains(formatter.title ?? "")
                            }
                            
                            if !filteredItems.isEmpty {
                                GeometryReader { itemGeometry in
                                    VStack(alignment: .leading) {
                                        Text(category.name)
                                            .font(.title.monospaced())
                                            .padding(.leading, 12)
                                        
                                        ZStack(alignment: .topLeading) {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 12) {
                                                    ForEach(filteredItems) { item in
                                                        CardPreviewView(item: item)
                                                            .environment(\.modelContext, context)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .rotation3DEffect(.init(degrees: rotation(for: itemGeometry, in: geometry)),
                                                      axis: (x: 1, y: 0, z: 0),
                                                      anchor: .center
                                    )
                                }
                                .offset(x: 12)
                                .frame(height: 130)
                            }
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
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.thinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.gray, lineWidth: 0.5)
                            )
                        HStack {
                            if isSearchVisible {
                                TextField("Search", text: $searchText)
                                    .padding(.leading, 15)
                                    .cornerRadius(25)
                                    .monospaced()
                                    .textFieldStyle(.plain)
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
                    }
                    .frame(width: isSearchVisible ? 465 : 30, height: 30)
                    .shadow(color: .gray, radius: 30, x: 0, y: 5)
                    .cornerRadius(25)
                }
                .padding(.top, 15)
                .padding(.trailing, 15)
                , alignment: .topTrailing
            )
        }
    }
    
    func rotation(for itemGeometry: GeometryProxy, in containerGeometry: GeometryProxy) -> Double {
        let containerMidY = containerGeometry.frame(in: .global).midY
        let itemMidY = itemGeometry.frame(in: .global).midY
        let offset = itemMidY - containerMidY
        let progress = offset / containerGeometry.size.height
        let degree = progress * rotation
        return degree
    }
}
