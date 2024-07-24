//
//  FormNavigationLinkLabel.swift
//  Clipchop
//
//  Created by KrLite on 2024/6/1.
//
/*
import SwiftUI

struct FormNavigationLinkLabel<Content>: View where Content: View {
    var hasSpacer: Bool = true
    var alignment: VerticalAlignment = .center
    var spacing: CGFloat?
    var imagePadding: CGFloat = 6
    @ViewBuilder var content: () -> Content
    
    init(
        hasSpacer: Bool = true,
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        imagePadding: CGFloat = 6,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.hasSpacer = hasSpacer
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }
    
    init(
        _ titleKey: LocalizedStringKey,
        hasSpacer: Bool = true,
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        imagePadding: CGFloat = 6
    ) where Content == Text {
        self.init(hasSpacer: hasSpacer, alignment: alignment, spacing: spacing, imagePadding: imagePadding) {
            Text(titleKey)
        }
    }
    
    var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            content()
            
            if hasSpacer {
                Spacer()
            }
            
            Image(systemSymbol: .chevronForward)
                .foregroundStyle(.placeholder)
                .imageScale(.small)
                .fontWeight(.semibold)
                .padding(.vertical, imagePadding)
        }
    }
}
*/
