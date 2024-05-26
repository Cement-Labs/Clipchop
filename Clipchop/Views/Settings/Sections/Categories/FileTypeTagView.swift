//
//  FileTypeTagView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import SwiftUI

struct FileTypeTagView: View {
    var type: String
    @Binding var isDeleteButtonShown: Bool
    var onDelete: (String) -> Void
    
    var body: some View {
        Text(type)
            .monospaced()
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        
            .background(.placeholder.opacity(0.1))
            .clipShape(.rect(cornerRadius: 12))
        
            .wiggle(isAnimating: $isDeleteButtonShown)
        
            .overlay(alignment: .topTrailing) {
                if isDeleteButtonShown {
                    Button {
                        onDelete(type)
                    } label: {
                        Image(systemSymbol: .xmarkCircleFill)
                            .imageScale(.large)
                            .foregroundStyle(.red)
                    }
                    .buttonBorderShape(.circle)
                    .buttonStyle(.borderless)
                    
                    .offset(x: 5, y: -5)
                }
            }
        
            .contextMenu {
                Button("Remove", role: .destructive) {
                    onDelete(type)
                }
            }
    }
}
