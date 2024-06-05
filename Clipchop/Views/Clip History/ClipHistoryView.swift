//
//  ClipHistoryView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/16.
//

import SwiftUI
import SwiftData
import Defaults
import SFSafeSymbols

struct ClipHistoryView: View {
    
    @Query(sort: \ClipboardHistory.time, order: .reverse, animation: .spring(dampingFraction: 0.7)) private var items: [ClipboardHistory]
        
    @Environment(\.modelContext) var context
    @Environment(\.undoManager) private var undoManager
    
    @Namespace private var animationNamespace
    
    @State private var apps = InstalledApps()
    @State private var previousHeight: CGFloat = 100
    @State private var scrollPadding: CGFloat = 12
    @State private var initialScrollPadding: CGFloat = 12
    @State private var movethebutton = false
    @State private var isExpanded = false
    
    private let controller = ClipHistoryViewController()
    
    var body: some View {
        clip {
            ZStack {
                    Button(action: undo) { }
                    .disabled(!(undoManager?.canUndo ?? false))
                    .opacity(0)
                    .allowsHitTesting(false)
                    .buttonStyle(.borderless)
                    .keyboardShortcut("z", modifiers: .command)
                    .frame(width: 0, height: 0)
                    Button(action: redo) { }
                    .disabled(!(undoManager?.canRedo ?? false))
                    .opacity(0)
                    .allowsHitTesting(false)
                    .buttonStyle(.borderless)
                    .keyboardShortcut("z", modifiers: [.command, .shift])
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
                        if isExpanded {
                            ClipHistoryCategorization(animationNamespace: animationNamespace)
                        } else {
                            ZStack(alignment: .topLeading) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 12) {
                                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                                            let shortcut = index < 9 ? "\(index + 1)" : "none"
                                            CardPreviewView(item: item, keyboardShortcut: shortcut)
                                                .environmentObject(apps)
                                        }
                                    }
                                    .offset(x: scrollPadding)
                                    .background(GeometryReader { geometry in
                                        Color.clear
                                            .onChange(of: geometry.frame(in: .global).minX) { newValue, _ in
                                                let deltaFromInitial = newValue
                                                if deltaFromInitial >= 15 && !movethebutton {
                                                    performHapticFeedback()
                                                    withAnimation(.spring()) {
                                                        scrollPadding = 74
                                                        movethebutton = true
                                                        initialScrollPadding = scrollPadding
                                                    }
                                                } else if deltaFromInitial < -5 && movethebutton {
                                                    performHapticFeedback()
                                                    withAnimation(.spring()) {
                                                        scrollPadding = 12
                                                        movethebutton = false
                                                        initialScrollPadding = scrollPadding
                                                        
                                                    }
                                                }
                                            }
                                    })
                                    .overlay (
                                        VStack {
                                            VStack(spacing: 5){
                                                SettingsLink {
                                                    ZStack(alignment: .center) {
                                                        RoundedRectangle(cornerRadius: 5)
                                                            .fill(Color.accentColor)
                                                            .frame(width: 50, height: 38)
                                                        Image(systemSymbol: .gearshape)
                                                    }
                                                }
                                                .buttonStyle(.borderless)
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .fill(.red)
                                                        .frame(width: 50, height: 38)
                                                    Image(systemSymbol: .trash)
                                                }
                                                .onTapGesture {
                                                    showAlert()
                                                }
                                            }
                                            .frame(width: 50, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                        }
                                            .animation(.spring(), value: movethebutton)
                                            .offset(x: movethebutton ? 12 : -120),
                                        alignment: .leading)
                                }
                            }
                            .matchedGeometryEffect(
                                id: "clipHistory",
                                in: animationNamespace,
                                properties: .frame,
                                anchor: .center,
                                isSource: true
                            )
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onReceive(NotificationCenter.default.publisher(for: .didChangeExpansionState)) { notification in
            if let userInfo = notification.userInfo, let isExpanded = userInfo["isExpanded"] as? Bool {
                withAnimation(.easeInOut) {
                    self.isExpanded = isExpanded
                }
            }
        }
    }
    
    @ViewBuilder
    private func clip(@ViewBuilder content: @escaping () -> some View) -> some View {
        content()
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
    
    private func undo() {
        undoManager?.undo()
        
    }
    
    private func redo() {
        undoManager?.redo()
        
    }

    private func showAlert() {
        let alert = NSAlert()
        alert.messageText = "Clear Clipboard History"
        alert.informativeText = "This action clears all your clipboard history unrestorably, including pins."
        alert.alertStyle = .warning
        
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // TODO: Delete
            do {
                let container = try ModelContainer(for: ClipboardContent.self, ClipboardHistory.self)
                
                let context = ModelContext(container)
                
                let contentFetchDescriptor = FetchDescriptor<ClipboardContent>()
                let allClipboardContents = try context.fetch(contentFetchDescriptor)
                for content in allClipboardContents {
                    context.delete(content)
                }
                
                let historyFetchDescriptor = FetchDescriptor<ClipboardHistory>()
                let allClipboardHistories = try context.fetch(historyFetchDescriptor)
                for history in allClipboardHistories {
                    context.delete(history)
                }
                
                try context.save()
                
            } catch {
                log(self, "Failed to delete: \(error)")
            }
        }
    }
    
    func performHapticFeedback() {
        NSHapticFeedbackManager.defaultPerformer.perform(
            NSHapticFeedbackManager.FeedbackPattern.generic,
            performanceTime: NSHapticFeedbackManager.PerformanceTime.now
        )
    }
}
