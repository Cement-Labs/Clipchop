//
//  FormSectionList.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/28.
//

import SwiftUI
import SFSafeSymbols

struct FormSectionList<Content, Footer>: View where Content: View, Footer: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var footer: () -> Footer
    
    var body: some View {
        VStack(spacing: 0) {
            content()
            
            Divider()
            
            Rectangle()
                .frame(height: 20)
                .foregroundStyle(.quinary)
                .overlay {
                    HStack(spacing: 2) {
                        footer()
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
