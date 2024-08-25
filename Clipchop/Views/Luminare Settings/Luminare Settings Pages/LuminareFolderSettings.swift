//
//  LuminareFolderSettings.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/8/24.
//

import SwiftUI
import Luminare
import Defaults

struct LuminareFolderSettings: View {
    
    @Default(.folders) var folders
    @State private var isRenaming: Folder?
    @State private var newName: String = ""
    @State private var isPopoverPresented = false
    @State private var input: String = ""
    
    var filteredFolders: [Folder] {
        return Defaults[.folders].sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var body: some View {
        VStack {
            LuminareSection("You have created \(folders.count) folders") {
                VStack {
                    Button(action: {
                        isPopoverPresented.toggle()
                    }) {
                        Text("Add Folder")
                    }
                    .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom) {
                        VStack {
                            HStack {
                                TextField("Folder Name", text: $input)
                                    .monospaced()
                                    .textFieldStyle(.plain)
                                    .padding(2)
                                    .onSubmit {
                                        submitInput()
                                    }
                                
                                Button(action: {
                                    submitInput()
                                }) {
                                    Image(systemName: canSubmitInput ? "arrow.forward.circle.fill" : "exclamationmark.circle.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.borderless)
                                .buttonBorderShape(.circle)
                                .disabled(!canSubmitInput)
                            }
                            .padding(4)
                            .frame(minWidth: 225)
                            .padding()
                        }
                    }
                }
                ForEach(filteredFolders, id: \.id) { folder in
                    HStack {
                        if isRenaming?.id == folder.id {
                            TextField("", text: $newName, onCommit: {
                                renameFolder(folder, newName: newName)
                                isRenaming = nil
                            })
                            .textFieldStyle(.plain)
                        } else {
                            Text(folder.name)
                        }
                        Spacer()
                        HStack {
                            Button(action: {
                                isRenaming = folder
                                newName = folder.name
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.black)
                            }
                            .padding(.trailing, 10)
                            .buttonStyle(.borderless)
                            
                            Button(action: {
                                removeFolder(folder)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.black)
                            }
                            .buttonStyle(.borderless)
                        }
                        .clipShape(.capsule)
                        .monospaced()
                        .fixedSize()
                        .padding(4)
                        .padding(.horizontal, 4)
                        .background {
                            ZStack {
                                Capsule()
                                    .strokeBorder(.quaternary, lineWidth: 1)
                                
                                Capsule()
                                    .foregroundStyle(.quinary.opacity(0.5))
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.trailing, 2)
                    .frame(minHeight: 34, alignment: .leading)
                }
            }
        }
    }
    
    private var canSubmitInput: Bool {
        !input.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func submitInput() {
        guard canSubmitInput else { return }
        let folderManager = FolderManager()
        folderManager.addFolder(named: input)
        input = ""
        isPopoverPresented = false
    }
    
    private func renameFolder(_ folder: Folder, newName: String) {
        let folderManager = FolderManager()
        folderManager.removeFolder(named: folder.name)
        folderManager.addFolder(named: newName)
    }
    
    private func removeFolder(_ folder: Folder) {
        let folderManager = FolderManager()
        folderManager.removeFolder(named: folder.name)
    }
}
