//
//  CardPreviewView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/19.
//

import SwiftUI
import SwiftData
import Defaults
import SFSafeSymbols

struct CardPreviewView: View {
    private var sourceApp: NSRunningApplication? {NSWorkspace.shared.frontmostApplication}
    
    @Bindable var item: ClipboardHistory
    
    @State private var isSelected = false
    @State private var isHoveredPin = false
    @State private var data: Data?
    
    @Environment(\.modelContext) var context
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
    var pinIcon: String {
        item.pinned ? "pin.fill" : "pin"
    }
    
    var body: some View {
        ZStack {
            PreviewContentView(clipboardHistory: item)
                .frame(width: 80, height: 80, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 12.5))
                .allowsHitTesting(false)
            
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(item.pinned ? Material.ultraThin : Material.regular)
                    .fill(item.pinned ? Color.accentColor : Color.clear)
                    .scaleEffect(isHoveredPin ? 1.333 : 1)
                    .frame(width: 15, height: 15)
                    .onHover { isOverPin in
                        withAnimation {
                            isHoveredPin = isOverPin
                        }
                    }
                    .onTapGesture {
                        withAnimation(Animation.easeInOut) {
                            do{
                                item.pinned.toggle()
                            }
                        }
                    }
                
                Image(systemName: pinIcon)
                    .allowsHitTesting(false)
                    .rotationEffect(Angle.degrees(item.pinned ? 45 : 0))
                    .font(isHoveredPin ? .system(size: 10) : .system(size: 7.5))
            }
            .frame(maxWidth: .infinity,maxHeight:.infinity, alignment: .topTrailing)
            .padding(.top, 10)
            .padding(.trailing, 10)
            
            ZStack(alignment:.bottomLeading) {
                RoundedRectangle(cornerRadius: 0)
                    .fill(.thickMaterial)
                    .frame(width: 80, height: 30)
                
                HStack{
                    VStack{
                        Group {
                            if let title = item.formatter.title {
                                Text(title)
                            } else {
                                Text("Other")
                            }
                        }
                        .font(.system(size: 12.5).monospaced())
                        .minimumScaleFactor(0.5)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                    }
                }
                .padding(.all, 10)
            }
            .frame(maxWidth: .infinity,maxHeight:.infinity, alignment: .bottom)
        }
        .frame(width: 80, height: 80, alignment: .center)
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 12.5))
        
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 7.5)
                .frame(width: 80, height: 80)
                .foregroundColor(.clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .contextMenu {
            Button {
                withAnimation(Animation.easeInOut) {
                    do{
                        self.isHoveredPin = true
                        item.pinned.toggle()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(Animation.easeInOut) {
                        self.isHoveredPin = false
                    }
                }
            } label: {
                Text(item.pinned ? "Unpin" : "Pin")
                Image(systemSymbol: .pin)
            }
            
            Button {
                ModelManager.monitor?.copy(item)
            } label: {
                Text(Defaults[.paste] ? "Paste to \(sourceApp?.localizedName ?? "Unknown App")" : "copy")
                Image(systemSymbol: .docOnDoc)
            }

            Divider()
            
            Button {
                deleteItem(item)
            } label: {
                Text("Delete")
                Image(systemSymbol: .trash)
            }
        }
        .gesture(
            TapGesture(count: 2)
                .onEnded{
                    ModelManager.monitor?.copy(item)
                }
        )
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
    }
    private func deleteItem(_ item: ClipboardHistory) {
        if let contents = item.contents {
            for content in contents {
                context.delete(content)
            }
        }
        context.delete(item)
        do {
            try context.save()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
}
