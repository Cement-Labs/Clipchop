//
//  GeneralSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI

struct GeneralSettingsPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Section {
                Text("Test")
                Text("Test")
            } header: {
                Text("Permissions")
                    .font(.title)
                    .bold()
            }
        }
    }
}

#Preview {
    GeneralSettingsPage()
}
