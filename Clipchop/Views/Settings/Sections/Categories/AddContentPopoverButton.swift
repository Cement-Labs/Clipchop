//
//  AddContentPopoverButton.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import SwiftUI

struct AddContentPopoverButton<Label, Additional>: View where Label: View, Additional: View {
    @ViewBuilder var label: () -> Label
    @ViewBuilder var additional: () -> Additional
    var placeholderTitleKey: LocalizedStringKey
    var confirmTitleKey: LocalizedStringKey
    var arrowEdge: Edge = .bottom
    var action: (String) -> Void
    
    @State var input: String = ""
    @State var isPresented = false
    
    init(
        _ placeholderTitleKey: LocalizedStringKey,
        _ confirmTitleKey: LocalizedStringKey,
        arrowEdge: Edge = .bottom,
        action: @escaping (String) -> Void,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder additional: @escaping () -> Additional
    ) {
        self.label = label
        self.additional = additional
        self.placeholderTitleKey = placeholderTitleKey
        self.confirmTitleKey = confirmTitleKey
        self.arrowEdge = arrowEdge
        self.action = action
    }
    
    init(
        _ placeholderTitleKey: LocalizedStringKey,
        _ confirmTitleKey: LocalizedStringKey,
        arrowEdge: Edge = .bottom,
        action: @escaping (String) -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) where Additional == EmptyView {
        self.init(placeholderTitleKey, confirmTitleKey, arrowEdge: arrowEdge, action: action, label: label) {
            EmptyView()
        }
    }
    
    init(
        _ titleKey: LocalizedStringKey,
        _ placeholderTitleKey: LocalizedStringKey,
        _ confirmTitleKey: LocalizedStringKey,
        arrowEdge: Edge = .bottom,
        action: @escaping (String) -> Void,
        @ViewBuilder additional: @escaping () -> Additional
    ) where Label == Text {
        self.init(placeholderTitleKey, confirmTitleKey, arrowEdge: arrowEdge) {
            action($0)
        } label: {
            Text(titleKey)
        } additional: {
            additional()
        }
    }
    
    init(
        _ titleKey: LocalizedStringKey,
        _ placeholderTitleKey: LocalizedStringKey,
        _ confirmTitleKey: LocalizedStringKey,
        arrowEdge: Edge = .bottom,
        action: @escaping (String) -> Void
    ) where Label == Text, Additional == EmptyView {
        self.init(titleKey, placeholderTitleKey, confirmTitleKey, action: action) {
            EmptyView()
        }
    }
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            label()
        }
        .popover(isPresented: $isPresented, arrowEdge: arrowEdge) {
            VStack {
                TextField(placeholderTitleKey, text: $input)
                    .textFieldStyle(.plain)
                    .monospaced()
                
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    
                    Spacer()
                    
                    Button(confirmTitleKey) {
                        action(input)
                        
                        input = ""
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                additional()
            }
            .padding()
        }
    }
}
