//
//  CategoriesSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/28.
//

import SwiftUI
import Defaults

struct CategoriesSection: View {
    @Default(.fileTypes) private var fileTypes
    
    @State private var selection: FileType?
    
    var body: some View {
        FormSectionListContainer {
            NavigationStack {
                List(selection: $selection) {
                    ForEach(fileTypes) { type in
                        NavigationLink {
                            List {
                                ForEach(type.categories) { category in
                                    Text(category.name)
                                }
                            }
                        } label: {
                            HStack {
                                Text(type.ext)
                                    .monospaced()
                                
                                Spacer()
                                
                                Image(systemSymbol: .chevronForward)
                                    .foregroundStyle(.placeholder)
                            }
                            .contextMenu {
                                Button("Insert") {
                                    
                                }
                                
                                Button("Reset Categories", role: .destructive) {
                                    fileTypes.updateEach { mutableType in
                                        if mutableType == type {
                                            mutableType.categories = []
                                        }
                                    }
                                }
                                
                                Button("Delete", role: .destructive) {
                                    fileTypes.removeAll { $0 == type }
                                }
                            }
                        }
                        .padding(4)
                        .buttonStyle(.borderless)
                    }
                    .onMove { indexSet, destination in
                        fileTypes.move(fromOffsets: indexSet, toOffset: destination)
                    }
                    .onDelete { indexSet in
                        fileTypes.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.bordered)
                .alternatingRowBackgrounds()
            }
        }
    }
    
    private func removeSelected() {
        fileTypes.removeAll { $0 == selection }
        selection = nil
    }
}
