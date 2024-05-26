//
//  FileTypeListView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileTypeListView<Label>: View where Label: View {
    @ViewBuilder var label: () -> Label
    
    @Binding var types: [String]
    
    @State private var isCollapsed = false
    
    var onDropOf: [UTType] = []
    var onDropDelegate: DropDelegate?
    var onDelete: Optional<(IndexSet) -> Void> = { _ in }
    
    init(
        types: Binding<[String]>,
        onDropOf: [UTType] = [],
        onDropDelegate: DropDelegate? = nil,
        onDelete: @escaping (IndexSet) -> Void = { _ in },
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label
        self._types = types
        
        self.onDelete = onDelete
        self.onDropOf = onDropOf
        self.onDropDelegate = onDropDelegate
    }
    
    init(
        _ titleKey: LocalizedStringKey,
        types: Binding<[String]>,
        onDropOf: [UTType] = [],
        onDropDelegate: DropDelegate? = nil,
        onDelete: @escaping (IndexSet) -> Void = { _ in }
    ) where Label == Text {
        self.init(types: types, onDropOf: onDropOf, onDropDelegate: onDropDelegate, onDelete: onDelete) {
            Text(titleKey)
        }
    }
    
    @ViewBuilder
    func buildTagEntry(_ type: String) -> some View {
        HStack {
            FileTypeTagView(type: type) { type in
                types.removeAll { $0 == type }
            }
            .onDrag {
                NSItemProvider(object: type as NSString)
            }
        }
    }
    
    var body: some View {
        Section {
            if isCollapsed {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(types, id: \.self) { type in
                            buildTagEntry(type)
                        }
                        .onDelete(perform: onDelete)
                    }
                    
                }
            } else {
                WrappingHStack(
                    models: types, lineSpacing: 8,
                    onDropOf: onDropOf, onDropDelegate: onDropDelegate
                ) { type in
                    buildTagEntry(type)
                }
            }
        } header: {
            HStack {
                label()
                
                Spacer()
                
                Button {
                    withAnimation {
                        isCollapsed.toggle()
                    }
                } label: {
                    Image(systemSymbol: isCollapsed ? .chevronDown : .minus)
                        .contentTransition(.symbolEffect(.replace.offUp))
                        .frame(width: 22, height: 16)
                }
                .buttonStyle(.borderless)
            }
        }
        .animation(.interactiveSpring, value: types)
        .if(onDropDelegate != nil) { view in
            view.onDrop(of: onDropOf, delegate: onDropDelegate!)
        }
    }
}
