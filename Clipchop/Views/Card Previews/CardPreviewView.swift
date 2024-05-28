//
//  CardPreviewView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/19.
//

import SwiftUI
import SwiftData
import Defaults

struct CardPreviewView: View {
    var item: ClipboardHistory
    
    @State private var isSelected = false
    @State private var data: Data?
    
    @Environment(\.modelContext) var context
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var body: some View {
        VStack{
            PreviewContentView(clipboardHistory: item)
                .clipShape(.rect(cornerRadius: 12.5))
        }
        .allowsHitTesting(false)
        .frame(width: 80, height: 80, alignment: .center)
        .clipShape(.rect(cornerRadius: 12.5))
        
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 7.5)
        )
        .background(backgroundColor)
        
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        
        .onHover { isOver in
            withAnimation(Animation.easeInOut) {
                self.isSelected = isOver
            }
        }
        .onDrag {
            let clipboardContents = item.getContents()
            for content in clipboardContents {
                if let itemProvider = dragManager(for: content) {
                    return itemProvider
                }
            }
            
            log(self, "No suitable content found for dragging")
            return NSItemProvider()
        }
        .gesture(
            TapGesture(count: 2)
                .onEnded {
                    let clipboardMonitor = ClipboardMonitor(context: context)
                    clipboardMonitor.copy(item)
                }
        )
    }
}
