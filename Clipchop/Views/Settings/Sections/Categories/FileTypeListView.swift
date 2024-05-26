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
    
    //var onDelete: (IndexSet) -> Void
    //var dropTypes: [UTType]
    //var dropDelegate: DropDelegate
    
    init(
        types: Binding<[String]>,
        //dropTypes: [UTType],
        //dropDelegate: DropDelegate,
        //onDelete: @escaping (IndexSet) -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label
        self._types = types
        
        //self.onDelete = onDelete
        //self.dropTypes = dropTypes
        //self.dropDelegate = dropDelegate
    }
    
    init(
        _ titleKey: LocalizedStringKey,
        types: Binding<[String]>//,
        //dropTypes: [UTType],
        //dropDelegate: DropDelegate,
        //onDelete: @escaping (IndexSet) -> Void
    ) where Label == Text {
        self.init(types: types/*, dropTypes: dropTypes, dropDelegate: dropDelegate, onDelete: onDelete*/) {
            Text(titleKey)
        }
    }
    
    @ViewBuilder
    func buildTagEntry(_ type: String) -> some View {
        FileTypeTagView(type: type)
            .onDrag {
                NSItemProvider(object: type as NSString)
            }
    }
    
    /*
    @ViewBuilder
    func handleEvents(content: () -> some View) -> some View {
        content()
            .onDelete(onDelete)
            .onDrop(of: dropTypes, delegate: dropDelegate)
    }
     */
    
    var body: some View {
        Section {
            if isCollapsed {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(types, id: \.self) { type in
                            buildTagEntry(type)
                        }
                    }
                }
            } else {
                WrappingHStack(models: types, lineSpacing: 8) { type in
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
    }
}
