//
//  LuminareCategorizationSettings.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/27.
//

import SwiftUI
import Luminare
import Defaults
import UniformTypeIdentifiers

struct LuminareCategorizationSettings: View {
    
    @Default(.categories) var categories
    @Default(.allTypes) var allTypes
    
    @State private var showCategorizationSheet = false
    @State private var input: String = ""
    @State private var isRenaming: FileCategory?
    @State private var newName = ""
    @State private var eventMonitor: Any?
    @State private var showingAlert = false
    
    var filteredCategories: [FileCategory] {
        return Defaults[.categories].sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var body: some View {
        LuminareSection("You have collected \(allTypes.count) types of files") {
            VStack {
                Button("Edit") {
                    showCategorizationSheet.toggle()
                }
                .sheet(isPresented: $showCategorizationSheet) {
                    CategorizationSection()
                        .frame(width: 600, height: 500)
                }
            }
            ForEach(filteredCategories, id: \.name) { category in
                HStack {
                    if isRenaming?.id == category.id {
                        TextField("",text: $newName, onCommit: {
                            renameCategory(category, newName: newName)
                            isRenaming = nil
                        })
                        .textFieldStyle(.plain)
                    } else {
                        Text(category.name)
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            isRenaming = category
                            newName = category.name
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.black)
                        }
                        .padding(.trailing, 10)
                        .buttonStyle(.borderless)
                        Button(action: {
                            removeCategory(category)
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
                .frame(minHeight: 34,alignment: .leading)
            }
        }
    }
    
    private func removeCategory(_ category: FileCategory) {
        categories.removeAll { $0 == category }
    }
    
    private func renameCategory(_ category: FileCategory, newName: String) {
        if let index = categories.firstIndex(of: category) {
            categories[index].name = newName
            Defaults[.categories] = categories
        }
    }
}
