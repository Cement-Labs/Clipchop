//
//  TestSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/18.
//

import SwiftUI

struct TestSettingsPage: View {
    var body: some View {
        ListEmbeddedForm {
            Button {
                MetadataCache.shared.clearAllCaches()
            } label: {
                Text("clearAllCaches")
            }
        }
    }
}
