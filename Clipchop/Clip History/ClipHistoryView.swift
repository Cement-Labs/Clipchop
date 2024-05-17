//
//  ClipHistoryView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import SwiftUI

struct ClipHistoryView: View {
    @ViewBuilder
    func clip(content: () -> some View) -> some View {
        content()
            .clipShape(.rect(cornerRadius: 25, style: .continuous))
    }
    
    var body: some View {
        clip {
            ZStack {
                clip {
                    VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
                }
                
                VStack(alignment: .center) {
                    Image(.appSymbol)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                    Text("No Clipboard History Available")
                }
                .foregroundStyle(.blendMode(.overlay))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ClipHistoryView()
}
