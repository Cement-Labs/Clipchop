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
    @State private var chosenInsertionPopoverElement: Chosen<FileType?> = .no
    
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
                                        chosenInsertionPopoverElement = .yes(type)
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
                                
                                // Requires a non-transparent background to expand the hit testing area
                                .background(.placeholder.opacity(0.0001))
                            }
                            .padding(.vertical, 4)
                            .buttonStyle(.borderless)
                            
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button("Insert") {
                                    chosenInsertionPopoverElement = .yes(type)
                                }
                                .tint(.accentColor)
                            }
                            .popover(isPresented: .init {
                                chosenInsertionPopoverElement == .yes(type)
                            } set: { _ in
                                chosenInsertionPopoverElement = .no
                            }) {
                                NewElementPopover("file extension") { ext in
                                    chosenInsertionPopoverElement = .no
                                }
                                .monospaced()
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
                            chosenInsertionPopoverElement = .yes(nil)
                        } label: {
                            Image(systemSymbol: .plus)
                        }
                        .popover(isPresented: .init {
                            chosenInsertionPopoverElement == .yes(nil)
                        } set: { _ in
                            chosenInsertionPopoverElement = .no
                        }) {
                            NewElementPopover("file extension") { ext in
                                chosenInsertionPopoverElement = .no
                            }
                            .monospaced()
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
