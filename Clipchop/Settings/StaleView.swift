//
//  StaleView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/15.
//

import SwiftUI

struct StaleView: View {
    var body: some View {
        Image(.appSymbol)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.placeholder)
        
            .frame(height: 64)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
