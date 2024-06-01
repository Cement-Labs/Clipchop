//
//  FileTypeListSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/28.
//

import SwiftUI
import Defaults

struct FileTypeListSection: View {
    @Default(.fileTypes) private var fileTypes
    
    @State private var selection: FileType?
    
    var body: some View {
        Section("File Types") {
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
                                .navigationTitle(type.ext.uppercased())
                            } label: {
                                FormNavigationLinkLabel {
                                    Text(type.ext)
                                        .monospaced()
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
                            .padding(.vertical, 4)
                            .buttonStyle(.borderless)
                            
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button("Insert") {
                                    
                                }
                                .tint(.accentColor)
                            }
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
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button {
                            
                        } label: {
                            Image(systemSymbol: .plus)
                        }
                    }
                }
            }
        }
    }
    
    private func removeSelected() {
        fileTypes.removeAll { $0 == selection }
        selection = nil
    }
}
