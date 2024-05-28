//
//  NavigationEntry.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import SwiftUI

struct NavigationEntry<TextLabel, ImageLabel>: View where TextLabel: View, ImageLabel: View {
    @ViewBuilder var title: () -> TextLabel
    @ViewBuilder var icon: () -> ImageLabel
    
    init(
        @ViewBuilder title: @escaping () -> TextLabel,
        @ViewBuilder icon: @escaping () -> ImageLabel
    ) {
        self.title = title
        self.icon = icon
    }
    
    init(
        _ titleKey: LocalizedStringKey,
        @ViewBuilder icon: @escaping () -> ImageLabel
    ) where TextLabel == Text {
        self.init {
            Text(titleKey)
        } icon: {
            icon()
        }
    }
    
    var body: some View {
        HStack {
            icon()
                .imageScale(.large)
                .frame(width: 24)
                .bold()
            
            title()
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 7.5)
    }
}
