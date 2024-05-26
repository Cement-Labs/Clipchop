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
    
    @State private var totalHeight: CGFloat = .zero
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
    
    var body: some View {
        Section {
            WrappingHStack(types, id: \.self) { type in
                FileTypeTagView(type: type)
                    .onDrag {
                        NSItemProvider(object: type as NSString)
                    }
            }
        } header: {
            HStack {
                label()
                
                Spacer()
                
                Button {
                    withAnimation(.default.speed(5)) {
                        isCollapsed.toggle()
                    }
                } label: {
                    Image(systemSymbol: isCollapsed ? .minus : .chevronDown)
                        .contentTransition(.symbolEffect(.replace.offUp))
                }
                .buttonStyle(.borderless)
                .buttonBorderShape(.circle)
            }
        }
    }
}
