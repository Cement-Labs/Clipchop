//
//  ClipHistoryView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import SwiftUI
import SwiftData

struct ClipHistoryView: View {
    
    @Query(sort: \ClipboardHistory.time, order: .reverse, animation: .smooth) private var items: [ClipboardHistory]
    
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
                if items.isEmpty {
                    VStack(alignment: .center) {
                        Image(.appSymbol)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 24)
                        Text("No Clipboard History Available")
                    }
                    .foregroundStyle(.blendMode(.overlay))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(items) { item in
                                CardPreviewView(item: item)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            print("Items: \(items)")
        }
    }
}

//#Preview {
//    ClipHistoryView()
//}
