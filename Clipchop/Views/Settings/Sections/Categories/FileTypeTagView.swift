//
//  FileTypeTagView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import SwiftUI

struct FileTypeTagView: View {
    var type: String
    
    var body: some View {
        Text(type)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
            }
            .clipShape(.rect(cornerRadius: 16))
            .padding(4)
    }
}
