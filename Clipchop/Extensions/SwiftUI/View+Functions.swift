//
//  View+Functions.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/25.
//

import SwiftUI

@ViewBuilder
func description(@ViewBuilder label: () -> some View) -> some View {
    label()
        .font(.caption)
        .foregroundStyle(.secondary)
}

@ViewBuilder
func withCaption(
    condition: Bool = true,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> some View,
    @ViewBuilder caption: () -> some View
) -> some View {
    VStack(alignment: .leading, spacing: spacing) {
        content()
        
        if condition {
            description {
                caption()
            }
        }
    }
}

@ViewBuilder
func withCaption(
    _ descriptionKey: LocalizedStringKey,
    condition: Bool = true,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> some View
) -> some View {
    withCaption(condition: condition, spacing: spacing) {
        content()
    } caption: {
        Text(descriptionKey)
    }
}

@ViewBuilder
func listEmbeddedForm(formStyle: some FormStyle = .grouped, @ViewBuilder content: () -> some View) -> some View {
    List {
        Form {
            content()
        }
        .formStyle(formStyle)
        
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .ignoresSafeArea()
    }
    .background(.white)
}

@ViewBuilder
func previewSection(content: () -> some View) -> some View {
    previewPage {
        Form {
            content()
        }
    }
}

@ViewBuilder
func previewPage(content: () -> some View) -> some View {
    content()
        .formStyle(.grouped)
}
