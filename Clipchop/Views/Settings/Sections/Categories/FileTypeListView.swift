//
//  FileTypeListView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import SwiftUI
import WrappingHStack

struct FileTypeListView<Label>: View where Label: View {
    @ViewBuilder var label: () -> Label
    
    @Binding var types: [String]
    
    @State private var isCollapsed = false
    
    init(
        types: Binding<[String]>,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label
        self._types = types
    }
    
    init(
        _ titleKey: LocalizedStringKey,
        types: Binding<[String]>
    ) where Label == Text {
        self.init(types: types) {
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
                WrappingHStack(types, id: \.self, lineSpacing: 8) { type in
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
    }
}
