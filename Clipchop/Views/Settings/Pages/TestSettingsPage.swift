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
            LazyVStack(pinnedViews: [.sectionHeaders, .sectionFooters]) {
                Color.red.frame(height: 100)
                
                Section {
                    ForEach(0..<100) { number in
                        HStack {
                            Text("Test line No.\(number)")
                            Spacer()
                        }
                    }
                    .padding()
                } header: {
                    Text("Header")
                } footer: {
                    Text("Footer")
                }
                
                Color.blue.frame(height: 100)
            }
        }
    }
}
