//
//  MenuBarIcon.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI

struct MenuBarIcon: View {
    var body: some View {
        Image("AppSymbol")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 22)
    }
}

#Preview {
    MenuBarIcon()
}
