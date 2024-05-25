//
//  RoamingButton.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/25.
//

import SwiftUI

struct RoamingButton<Label, Background>: View where Label: View, Background: View {
    var canHover = true
    var action: () -> Void
    @ViewBuilder var label: () -> Label
    @ViewBuilder var background: () -> Background
    
    @State var isHovering = false
    
    init(
        canHover: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder background: @escaping () -> Background
    ) {
        self.canHover = canHover
        self.action = action
        self.label = label
        self.background = background
    }
    
    init(
        canHover: Bool = true,
        action: @escaping () -> Void,
        label: @escaping () -> Label
    ) where Background == Color {
        self.init(canHover: canHover, action: action, label: label) {
            Color.clear
        }
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            label()
                .padding()
        }
        .background {
            background()
        }
        .padding()
        .scaleEffect(isHovering && canHover ? 1.05 : 1)
        
        .controlSize(.extraLarge)
        .buttonStyle(.borderless)
        .buttonBorderShape(.roundedRectangle(radius: 15))
        
        .onHover { isHovering in
            withAnimation {
                self.isHovering = isHovering
            }
        }
    }
}
