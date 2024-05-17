//
//  ClipHistoryView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import SwiftUI

struct ClipHistoryView: View {
    var body: some View {
        Group {
            Text("Test")
        }
        .frame(width: 500, height: 100, alignment: .center)
        .background(BlurView())
        .clipShape(.rect(cornerRadius: 25, style: .continuous))
    }
}

#Preview {
    ClipHistoryView()
}
