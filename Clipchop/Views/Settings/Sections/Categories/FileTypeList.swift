//
//  FileTypeList.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import SwiftUI

struct FileTypeList<Label>: View where Label: View {
    @ViewBuilder var label: () -> Label
    
    @Binding var types: [String]
    
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
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(types, id: \.self) { tag in
                        Group {
                            Text(tag)
                                .font(.headline)
                                .padding()
                        }
                        .onDrag {
                            NSItemProvider(object: tag as NSString)
                        }
                    }
                }
            }
        } header: {
            label()
        }
    }
}
