//
//  CardPreviewView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/19.
//

import AppKit
import SwiftUI
import Defaults
import SFSafeSymbols

struct CardPreviewView: View {
    
    private var sourceApp: NSRunningApplication? {NSWorkspace.shared.frontmostApplication}
    
    @Default(.removeFormatting) private var removeFormatting
    
    @ObservedObject var item: ClipboardHistory
    
    @State private var isSelected = false
    @State private var isHoveredPin = false
    @State private var data: Data?
    @State private var showMore = false
    
    @EnvironmentObject private var apps: InstalledApps
    @Environment(\.managedObjectContext) var context
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        withAnimation {
            colorScheme == .dark ? .black : .white
        }
    }
    var pinIcon: String {
        withAnimation {
            item.pin ? "pin.fill" : "pin"
        }
    }
    
    var keyboardShortcut: String
    var provider = ClipboardDataProvider.shared
    
    var body: some View {
        ZStack {
            // MARK: - Button Action
            Button("Delete", action:{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(dampingFraction: 0.7)){
                        try? deleteItem(item)
                    }
                }
            })
            .opacity(0)
            .allowsHitTesting(false)
            .buttonStyle(.borderless)
            .frame(width: 0, height: 0)
            .applyKeyboardShortcut(keyboardShortcut, modifier: .control)
            
            Button("Copy", action: {
                self.isSelected = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(Animation.spring(dampingFraction: 0.7)) {
                        self.isSelected = false
                    }
                    ClipboardManager.clipboardController?.copy(item)
                }
            })
            .opacity(0)
            .allowsHitTesting(false)
            .buttonStyle(.borderless)
            .frame(width: 0, height: 0)
            .applyKeyboardShortcut(keyboardShortcut, modifier: .command)
            
            if !Defaults[.removeFormatting] {
                Button("Copy as plain text", action: {
                    self.isSelected = true
                    removeFormatting = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(Animation.spring(dampingFraction: 0.7)) {
                            self.isSelected = false
                        }
                        ClipboardManager.clipboardController?.copy(item)
                        removeFormatting = false
                    }
                })
                .opacity(0)
                .allowsHitTesting(false)
                .buttonStyle(.borderless)
                .frame(width: 0, height: 0)
                .applyKeyboardShortcut(keyboardShortcut, modifier: [.shift, .command])
            }
            
            Button("Pin", action: {
                withAnimation(Animation.easeInOut) {
                    do{
                        self.isHoveredPin = true
                        item.pin.toggle()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(Animation.easeInOut) {
                        self.isHoveredPin = false
                    }
                }
            })
            .opacity(0)
            .allowsHitTesting(false)
            .buttonStyle(.borderless)
            .frame(width: 0, height: 0)
            .applyKeyboardShortcut(keyboardShortcut, modifier: .option)
            
            // MARK: - CardView
            PreviewContentView(clipboardHistory: item)
                .frame(width: 80, height: 80, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .allowsHitTesting(false)

            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(item.pin ? Material.ultraThin : Material.regular)
                    .fill(item.pin ? Color.getAccent() : Color.clear)
                    .scaleEffect(isHoveredPin ? 1.333 : 1)
                    .frame(width: 15, height: 15)
                    .onHover { isOverPin in
                        withAnimation {
                            isHoveredPin = isOverPin
                        }
                    }
                Image(systemName: pinIcon)
                    .allowsHitTesting(false)
                    .rotationEffect(Angle.degrees(item.pin ? 45 : 0))
                    .font(isHoveredPin ? .system(size: 10) : .system(size: 7.5))
            }
            .onTapGesture {
                withAnimation(Animation.easeInOut) {
                    do{
                        pinClipItem()
                    }
                }
            }
            .frame(maxWidth: .infinity,maxHeight:.infinity, alignment: .topTrailing)
            .padding(.top, 10)
            .padding(.trailing, 10)
            
            ZStack(alignment:.bottomLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.thickMaterial)
                    .frame(width: 70, height: 30)
                    .shadow(radius: 2.5)
                
                HStack{
                    if keyboardShortcut != "none" {
                        ZStack(alignment: .center){
                            RoundedRectangle(cornerRadius: 5)
                                .fill(backgroundColor)
                                .frame(width: 13, height: 13)
                            Text(keyboardShortcut)
                                .font(.system(size: 10))
                        }
                    }
                    Group {
                        if let title = item.formatter.title {
                            let fileExtensions = title.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                            let categorizedTitle = categorizeFileExtensions(fileExtensions)
                            Text(categorizedTitle)
                        } else {
                            Text("Other")
                        }
                    }
                    .font(.system(size: 12.5))
                    .minimumScaleFactor(0.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                }
                .padding(.all, 7.5)
            }
            .padding(.all, 5)
            .frame(maxWidth: .infinity,maxHeight:.infinity, alignment: .bottom)
        }
        .frame(width: 80, height: 80, alignment: .center)
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 12.5))
        .overlay(
            ZStack{
                if showMore && isSelected {
                    RoundedRectangle(cornerRadius: 15)
                        .fill( Material.ultraThin)
                        .frame(width: 80, height: 80)
                    VStack(spacing: 2) {
                        if let bundleID = item.appid, let appIcon = getAppIcon(byBundleID: bundleID) {
                            Image(nsImage: appIcon.resized(to: .init(width: 20, height: 20)))
                        }
                        if let bundleID = item.appid, let appDisplayName = getAppDisplayName(byBundleID: bundleID) {
                            Text(appDisplayName)
                                .font(.system(size: 10).monospaced())
                                .minimumScaleFactor(0.1)
                                .lineLimit(1)
                                .padding(.horizontal, 5)
                        }
                        Text(formattedDate(from: item.time!))
                            .font(.system(size: 7.5).monospaced())
                            .minimumScaleFactor(0.8)
                            .lineLimit(10)
                            .fixedSize(horizontal: false, vertical: false)
                        Text(relativeTime(from: item.time!))
                            .font(.system(size: 7.5).monospaced())
                            .minimumScaleFactor(0.8)
                            .lineLimit(10)
                            .fixedSize(horizontal: false, vertical: false)
                    }
                }
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.getAccent() : Color.clear, lineWidth: isSelected ? 8 : 0)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.clear)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .contextMenu(menuItems: {
            Button {
                withAnimation(Animation.easeInOut) {
                    do {
                        self.isHoveredPin = true
                        pinClipItem()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(Animation.easeInOut) {
                        self.isHoveredPin = false
                    }
                }
            } label: {
                Text(item.pin ? "Unpin" : "Pin")
                Image(systemSymbol: .pin)
            }
            .applyKeyboardShortcut(keyboardShortcut, modifier: .option)
            
            Button {
                ClipboardManager.clipboardController?.copy(item)
            } label: {
                if Defaults[.pasteToFrontmostEnabled] {
                    if let name = sourceApp?.localizedName {
                        Text("Paste to \(name)")
                    } else {
                        Text("Paste to Frontmost")
                    }
                } else {
                    Text("Copy to Clipboard")
                }
                Image(systemSymbol: .docOnClipboard)
            }
            .applyKeyboardShortcut(keyboardShortcut, modifier: .command)
            
            if !Defaults[.removeFormatting] {
                Button {
                    removeFormatting = true
                    ClipboardManager.clipboardController?.copy(item)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        removeFormatting = false
                    }
                } label: {
                    if Defaults[.pasteToFrontmostEnabled] {
                        if let name = sourceApp?.localizedName {
                            Text("Paste as Plain Text to \(name)")
                        } else {
                            Text("Paste as Plain Text to Frontmost")
                        }
                    } else {
                        Text("Copy as Plain Text to Clipboard")
                    }
                    Image(systemSymbol: .docOnDoc)
                }
                .applyKeyboardShortcut(keyboardShortcut, modifier: [.shift, .command])
            }
            
            Divider()
            
            Button {
                try? deleteItem(item)
            } label: {
                Text("Delete")
                Image(systemSymbol: .trash)
            }
            .applyKeyboardShortcut(keyboardShortcut, modifier: .control)
        })
        .gesture(
            TapGesture(count: 2)
                .onEnded{
                    ClipboardManager.clipboardController?.copy(item)
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
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { event in
                if event.modifierFlags.contains(.shift) {
                    withAnimation{
                        showMore = true
                    }
                } else {
                    withAnimation{
                        showMore = false
                    }
                }
                return event
            }
        }
    }
    func pinClipItem(){
        let currentPinStatus = item.pin
        item.pin.toggle()
        do{
            if context.hasChanges{
                try context.save()
            }
        } catch {
            log(self, "Failed to save pin status change: \(error)")
            item.pin = currentPinStatus
        }
    }
    
    private func deleteItem(_ item: ClipboardHistory) throws {
        let context = provider.viewContext
        let existingItem = try context.existingObject(with: item.objectID)
        context.delete(existingItem)
        Task(priority: .background) {
            try await context.perform {
                try context.save()
            }
        }
    }
    
    func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"
        return dateFormatter.string(from: date)
    }

    func relativeTime(from date: Date) -> String {
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .full
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
    
    func getAppIcon(byBundleID bundleID: String) -> NSImage? {
        if let app = (apps.installedApps + apps.systemApps).first(where: { $0.bundleID == bundleID }) {
            return app.icon
        }
        return nil
    }
    
    func getAppDisplayName(byBundleID bundleID: String) -> String? {
        if let app = (apps.installedApps + apps.systemApps).first(where: { $0.bundleID == bundleID }) {
            return app.displayName.replacingOccurrences(of: ".app", with: "")
        }
        return nil
    }
    
    func categorizeFileExtensions(_ fileExtensions: [String]) -> String {
        let categories = Defaults[.categories]
        for fileExtension in fileExtensions {
            if let category = categories.first(where: { $0.types.contains(fileExtension) }) {
                return category.name
            }
        }
        return fileExtensions.joined(separator: ", ")
    }
}
