//
//  CustomLuminarePicker.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/28.
//

import SwiftUI

struct CustomLuminarePicker<Item: Hashable & Equatable>: View {
    @Binding var selection: Item
    let items: [Item]
    let displayText: (Item) -> String

    init(selection: Binding<Item>, items: [Item], displayText: @escaping (Item) -> String = { String(describing: $0) }) {
        self._selection = selection
        self.items = items
        self.displayText = displayText
    }

    var body: some View {
        Menu {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    selection = item
                }) {
                    Text(displayText(item))
                }
                .buttonStyle(.borderless)
            }
        } label: {
            Text(displayText(selection))
                .foregroundColor(.primary)
        }
        .menuStyle(.borderlessButton)
        .frame(maxWidth: 150)
        .clipShape(Capsule())
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
}


