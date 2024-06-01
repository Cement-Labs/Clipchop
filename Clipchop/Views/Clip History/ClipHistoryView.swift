//
//  ClipHistoryView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import SwiftUI
import SwiftData
import Defaults

struct ClipHistoryView: View {
    @Query(
        sort: \ClipboardHistory.time,
        order: .reverse,
        animation: .spring(dampingFraction: 0.7)
    ) private var items: [ClipboardHistory]
    
    @Environment(\.modelContext) var context
        
    var body: some View {
        clip {
            ZStack {
                clip {
                    VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                }
                
                VStack{
                    if items.isEmpty {
                        // Placeholder
                        VStack(alignment: .center) {
                            Image(.clipchopFill)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 24)
                            Text("No Clipboard History Available")
                        }
                        .foregroundStyle(.blendMode(.overlay))
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(items) { items in
                                    CardPreviewView(item: items)
                                        .environment(\.modelContext, context)
                                }
                            }
                            .offset(x: 12)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    private func clip(@ViewBuilder content: @escaping () -> some View) -> some View {
        content()
            .clipShape(.rect(cornerRadius: 25, style: .continuous))
    }
}
