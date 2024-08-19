//
//  EmptyStateView.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/8.
//

import SwiftUI
import Defaults

struct EmptyStatePages: View {
    @Default(.preferredColorScheme) private var preferredColorScheme
    
    var body: some View {
        VStack(alignment: .center) {
            Image(.clipchopFill)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 24)
            Text("No Clipboard History Available")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .foregroundStyle(.blendMode(.overlay))
        .preferredColorScheme(preferredColorScheme.colorScheme)
    }
}
