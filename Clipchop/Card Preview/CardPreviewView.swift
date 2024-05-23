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
        
    @Environment(\.managedObjectContext) var context
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme
    
    var item: ClipboardHistory
    
    @State private var isSelected = false
    @State private var data: Data?
    
    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var body: some View {
        ZStack {
            ZStack {
                VStack{
                    PreviewContentView(clipboardHistory: item)
                }
                .allowsHitTesting(false)
                .frame(width: 80, height: 80, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 12.5))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 7.5)
        )
        .onHover { isOver in
            withAnimation(Animation.easeInOut) {
                self.isSelected = isOver
            }
        }
        .background(backgroundColor)
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .onDrag {
            let clipboardContents = item.getContents()
            for content in clipboardContents {
                if let itemProvider = DragManager(for: content) {
                    return itemProvider
                }
            }
            print("No suitable content found for dragging.")
            return NSItemProvider()
        }
    }
}

//#Preview {
//    CardPreviewView()
//}
