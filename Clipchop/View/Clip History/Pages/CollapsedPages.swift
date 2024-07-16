//
//  CollapsedPages.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/7.
//

import SwiftUI

struct CollapsedPages: View {
    
    var items: FetchedResults<ClipboardHistory>
    var animationNamespace: Namespace.ID
    
    @Binding var scrollPadding: CGFloat
    @Binding var initialScrollPadding: CGFloat
    @Binding var movethebutton: Bool
    
    var clipboardModelEditor: ClipboardModelEditor
    var apps: InstalledApps
    var undo: () -> Void
    var redo: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        CardPreviewView(item: item, keyboardShortcut: getKeyboardShortcut(for: index))
                            .environmentObject(apps)
                            .applyMatchedGeometryEffect(if: index < 6, id: item.id, namespace: animationNamespace)
                    }
                }
                .padding(.horizontal, scrollPadding)
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
                .overlay(
                    VStack {
                        VStack(spacing: 5) {
                            SettingsLink {
                                ZStack(alignment: .center) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.getAccent())
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
                    alignment: .leading
                )
            }
        }
        .frame(width: 500, height: 100)
    }
    
    private func getKeyboardShortcut(for index: Int) -> String {
        guard index < 9 else { return "none" }
        return String(index + 1)
    }
    
    private func performHapticFeedback() {
        NSHapticFeedbackManager.defaultPerformer.perform(
            NSHapticFeedbackManager.FeedbackPattern.generic,
            performanceTime: NSHapticFeedbackManager.PerformanceTime.now
        )
    }
    
    private func showAlert() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Clear Clipboard History", comment: "Alert message text for clearing clipboard history")
        alert.informativeText = NSLocalizedString("This action will clear all non-pinned entries from your clipboard history irreversibly.", comment: "Informative text for alert about clearing clipboard history")
        alert.alertStyle = .warning
        
        alert.addButton(withTitle: NSLocalizedString("Delete", comment: "Delete button title"))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel button title"))
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // TODO: Delete
            try? clipboardModelEditor.deleteAllExceptPinned()
        }
    }
}
