//
//  TestSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/18.
//

import SwiftUI

struct TestSettingsPage: View {
    var body: some View {
        ScrollView {
            ForEach(0..<100) { number in
                HStack {
                    Text("Test line No.\(number)")
                    Spacer()
                }
            }
            .padding()
        }
    }
}

#Preview {
    previewPage {
        TestSettingsPage()
    }
}
