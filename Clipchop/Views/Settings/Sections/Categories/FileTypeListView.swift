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
    @Binding var isInEditMode: Bool
    
    @State private var isCollapsed = false
    
    var onDropOf: [UTType] = []
    var onDropDelegate: DropDelegate?
    var onDelete: Optional<(IndexSet) -> Void> = { _ in }
    var onSingleDelete: (String) -> Void = { _ in }
    
    init(
        types: Binding<[String]>,
        isInEditMode: Binding<Bool>,
        onDropOf: [UTType] = [],
        onDropDelegate: DropDelegate? = nil,
        onDelete: @escaping (IndexSet) -> Void = { _ in },
        onSingleDelete: @escaping (String) -> Void = { _ in },
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label
        self._types = types
        self._isInEditMode = isInEditMode
        
        self.onDelete = onDelete
        self.onSingleDelete = onSingleDelete
        self.onDropOf = onDropOf
        self.onDropDelegate = onDropDelegate
    }
    
    init(
        _ titleKey: LocalizedStringKey,
        types: Binding<[String]>,
        isInEditMode: Binding<Bool>,
        onDropOf: [UTType] = [],
        onDropDelegate: DropDelegate? = nil,
        onDelete: @escaping (IndexSet) -> Void = { _ in },
        onSingleDelete: @escaping (String) -> Void = { _ in }
    ) where Label == Text {
        self.init(
            types: types,
            isInEditMode: isInEditMode,
            onDropOf: onDropOf, onDropDelegate: onDropDelegate,
            onDelete: onDelete, onSingleDelete: onSingleDelete
        ) {
            Text(titleKey)
        }
    }
    
    @ViewBuilder
    func buildTagEntry(_ type: String) -> some View {
        HStack {
            FileTypeTagView(type: type, isDeleteButtonShown: $isInEditMode, onDelete: onSingleDelete)
            .onDrag {
                isInEditMode = false
                return NSItemProvider(object: type as NSString)
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
                ZStack {
                    if types.isEmpty {
                        Text("Add Tag")
                            .monospaced()
                            .foregroundStyle(.gray)
                        Color.clear
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .if(onDropDelegate != nil) { view in
                                view.onDrop(of: onDropOf, delegate: onDropDelegate!)
                            }
                    }
                    WrappingHStack(
                        models: types, lineSpacing: 8,
                        onDropOf: onDropOf, onDropDelegate: onDropDelegate
                    ) { type in
                        buildTagEntry(type)
                    }
                    .if(onDropDelegate != nil) { view in
                        view.onDrop(of: onDropOf, delegate: onDropDelegate!)
                    }
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
                    Image(systemSymbol: isCollapsed ? .chevronDown : .chevronUp)
                        .contentTransition(.symbolEffect(.replace.offUp))
                        .frame(width: 22, height: 16)
                }
                .buttonStyle(.borderless)
            }
        }
        .animation(.interactiveSpring, value: types)
        
    }
}
