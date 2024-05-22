//
//  BeginningShortcutsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningShortcutsPage: View {
    var body: some View {
        Group {
            Text("Shortcuts")
        }
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    BeginningShortcutsPage()
}
