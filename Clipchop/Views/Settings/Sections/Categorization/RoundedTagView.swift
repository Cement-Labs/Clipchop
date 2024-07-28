//
//  RoundedTagView.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/6/2.
//

import SwiftUI
import SFSafeSymbols


struct RoundedTagView: View {

    @Binding var isDeleteButtonShown: Bool

    var text: String
    var onDelete: () -> Void

    var body: some View {
        HStack {
            Text(text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.placeholder.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))
                .overlay(alignment: .topTrailing){
                    if isDeleteButtonShown{
                        Button(action: onDelete) {
                            Image(systemSymbol: .xmarkCircleFill)
                                .foregroundColor(.red)
                        }
                        .offset(x: 5, y: -5)
                        .buttonStyle(.borderless)
                    }
                }
        }
    }
}
