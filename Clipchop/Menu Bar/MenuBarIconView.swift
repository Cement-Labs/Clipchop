//
//  MenuBarIconView.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import SFSafeSymbols

struct MenuBarIconView: View {
    var body: some View {
        Image(.clipchopFill)
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 18)
    }
}
