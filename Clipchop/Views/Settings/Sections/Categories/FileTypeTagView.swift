//
//  FileTypeTagView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import SwiftUI

struct FileTypeTagView: View {
    var type: String
    @State var isDeleteButtonShown: Bool = false
    var onDelete: (String) -> Void
    
    var body: some View {
        Text(type)
            .monospaced()
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        
            .background(.accent.opacity(0.1))
            .clipShape(.rect(cornerRadius: 12))
        
            .overlay(alignment: .topTrailing) {
                if isDeleteButtonShown {
                    Button {
                        onDelete(type)
                    } label: {
                        Image(systemSymbol: .xmark)
                    }
                    .buttonBorderShape(.circle)
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                } else {
                    Color.red
                }
            }
    }
}
