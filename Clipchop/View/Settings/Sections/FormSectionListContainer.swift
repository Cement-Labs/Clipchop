//
//  FormSectionListContainer.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/28.
//

import SwiftUI
import SFSafeSymbols

struct FormSectionListContainer<Content, Footer>: View where Content: View, Footer: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var footer: () -> Footer
    
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.content = content
        self.footer = footer
    }
    
    init(
        @ViewBuilder content: @escaping () -> Content
    ) where Footer == EmptyView {
        self.init(content: content) {
            EmptyView()
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content()
            
            if Footer.self != EmptyView.self {
                Divider()
                
                Rectangle()
                    .frame(height: 24)
                    .foregroundStyle(.quinary)
                    .overlay {
                        HStack(spacing: 2) {
                            footer()
                        }
                        .frame(height: 20)
                        .padding(2)
                    }
            }
        }
        .ignoresSafeArea()
        .padding(-10)
    }
}

struct FormSectionFooterLabel: View {
    var symbol: SFSymbol
    
    var body: some View {
        Rectangle()
            .foregroundStyle(.placeholder.opacity(0))
            .overlay {
                Image(systemSymbol: symbol)
                    .font(.footnote)
                    .fontWeight(.semibold)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(-5)
    }
}
