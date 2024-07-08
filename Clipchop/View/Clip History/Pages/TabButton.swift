//
//  TabButton.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/8.
//

import SwiftUI

struct TabButton: View {
    let title: String
    @Binding var selectedTab: String
    
    var body: some View {
        Button(action: {
            withAnimation(.default) {
                selectedTab = title
            }
        }) {
            Text(title)
                .padding()
                .background(selectedTab == title ? Color.accentColor : Color.clear)
                .foregroundColor(selectedTab == title ? Color.white : Color.primary)
                .cornerRadius(8)
        }
        .frame(maxWidth: 250, maxHeight: 30)
        .buttonStyle(.borderless)
        .cornerRadius(25)
    }
}
