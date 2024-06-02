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
    
    @State private var previousHeight: CGFloat = 100
    
    var body: some View {
        GeometryReader { geo in
            clip {
                ZStack {
                    clip {
                        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                    }
                    
                    VStack {
                        if items.isEmpty {
                            VStack(alignment: .center) {
                                Image(.clipchopFill)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 24)
                                Text("No Clipboard History Available")
                            }
                            .foregroundStyle(.blendMode(.overlay))
                        } else {
                            if previousHeight > 250 {
                                ClipHistoryCategorization()
                            }
                            if previousHeight < 250 {
                                ZStack(alignment: .topLeading) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(items) { item in
                                                CardPreviewView(item: item)
                                                    .environment(\.modelContext, context)
                                            }
                                        }
                                        .offset(x: 12)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .onAppear{
                DispatchQueue.main.async {
                    previousHeight = geo.size.height
                }
            }
            .onChange(of: geo.size.height) { newHeight, _ in
                withAnimation {
                    previousHeight = newHeight
                }
            }
        }
    }
    
    @ViewBuilder
    private func clip(@ViewBuilder content: @escaping () -> some View) -> some View {
        content()
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
}
