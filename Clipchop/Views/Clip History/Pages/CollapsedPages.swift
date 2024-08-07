//
//  CollapsedPages.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/7.
//

import SwiftUI
import Defaults

struct CollapsedPages: View {
    
    var items: FetchedResults<ClipboardHistory>
    var animationNamespace: Namespace.ID

    @State private var selectedIndex: Int? = nil
    @State private var eventLeft: Any?
    @State private var eventRight: Any?
    @State private var isOnHover: Bool = false
    @State private var shouldScroll: Bool = false

    @Binding var scrollPadding: CGFloat
    @Binding var initialScrollPadding: CGFloat
    @Binding var movethebutton: Bool

    @Default(.keySwitcher) var keySwitcher

    var clipboardModelEditor: ClipboardModelEditor
    var apps: InstalledApps
    var undo: () -> Void
    var redo: () -> Void

    var body: some View {
        ZStack(alignment: .center) {
            HStack {
                Button("selectNextItem") {
                    selectNextItem()
                }
                .opacity(0)
                .allowsHitTesting(false)
                .buttonStyle(.borderless)
                .frame(width: 0, height: 0)
                .keyboardShortcut(.tab, modifiers: keySwitcher.switchereventModifier)
                
                Button("selectPreviousItem1") {
                    selectPreviousItem()
                }
                .opacity(0)
                .allowsHitTesting(false)
                .buttonStyle(.borderless)
                .frame(width: 0, height: 0)
                .keyboardShortcut("`", modifiers: keySwitcher.switchereventModifier)
                
                Button("selectPreviousItem2") {
                    selectPreviousItem()
                }
                .opacity(0)
                .allowsHitTesting(false)
                .buttonStyle(.borderless)
                .frame(width: 0, height: 0)
                .keyboardShortcut("·", modifiers: keySwitcher.switchereventModifier)
                
                Button("esc") {
                    selectedIndex = nil
                }
                .opacity(0)
                .allowsHitTesting(false)
                .buttonStyle(.borderless)
                .frame(width: 0, height: 0)
                .keyboardShortcut(.escape, modifiers: keySwitcher.switchereventModifier)
            }
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: Defaults[.displayMore] ? 16 : 12) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            CardPreviewView(
                                item: item,
                                isSelected: isSelectedBinding(for: index),
                                keyboardShortcut: getKeyboardShortcut(for: index)
                            )
                            .id(index)
                            .environmentObject(apps)
                            .applyMatchedGeometryEffect(if: index < 6, id: item.id, namespace: animationNamespace)
                            .onHover { isOver in
                                isOnHover = isOver
                            }
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
                                        scrollPadding = Defaults[.displayMore] ? 16 : 12
                                        movethebutton = false
                                        initialScrollPadding = scrollPadding
                                    }
                                }
                            }
                    })
                    .overlay(
                        VStack(spacing: 5) {
                            Button (action: {
                                LuminareManager.open()
                            }, label: {
                                ZStack(alignment: .center) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.getAccent())
                                        .frame(width: 50, height: Defaults[.displayMore] ? 54 : 38)
                                    Image(systemSymbol: .gearshape)
                                }
                            })
                            .buttonStyle(.borderless)
                            Button (action: {
                                showAlert()
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.red)
                                        .frame(width: 50, height: Defaults[.displayMore] ? 54 : 38)
                                    Image(systemSymbol: .trash)
                                }
                            })
                            .buttonStyle(.borderless)
                        }
                        .frame(width: 50, height: Defaults[.displayMore] ? 112 : 80)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .animation(.spring(), value: movethebutton)
                        .offset(x: movethebutton ? 12 : -120), alignment: .leading)
                }
                .onChange(of: selectedIndex) { new, _ in
                    if !isOnHover {
                        shouldScroll.toggle()
                    }
                }
                .onChange(of: shouldScroll) { _, _ in
                    if let newIndex = selectedIndex {
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .trailing)
                        }
                        shouldScroll = false
                    }
                }
            }
        }
        .frame(width: Defaults[.displayMore] ? 700 : 500, height: Defaults[.displayMore] ? 140 : 100)
        .onAppear {
            setupEventMonitors()
        }
        .onDisappear {
            cleanupEventMonitors()
        }
        .onReceive(.panelDidClose) { _ in
            selectedIndex = nil
        }
    }
    
    private func setupEventMonitors() {
        eventRight = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            if event.type == .keyDown && event.keyCode == 123 {
                selectPreviousItem2()
                return nil
            }
            return event
        }

        eventLeft = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            if event.type == .keyDown && event.keyCode == 124 {
                selectNextItem2()
                return nil
            }
            return event
        }
    }
    
    private func cleanupEventMonitors() {
//         Remove event monitors to avoid leaks
        if let monitor = eventRight {
            NSEvent.removeMonitor(monitor)
            eventRight = nil
        }
        if let monitor = eventLeft {
            NSEvent.removeMonitor(monitor)
            eventLeft = nil
        }
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
    
    private func isSelectedBinding(for index: Int) -> Binding<Bool> {
        Binding(
            get: { self.selectedIndex == index },
            set: { isSelected in
                if isSelected {
                    self.selectedIndex = index
                } else if self.selectedIndex == index {
                    self.selectedIndex = nil
                }
            }
        )
    }
    
    private func selectItem(at index: Int) {
        if index >= 0 && index < items.count {
            selectedIndex = index
        }
    }
    
    private func selectPreviousItem() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let previousIndex = (currentIndex - 1 + 5) % 5
            let actualIndex = min(previousIndex, items.count - 1)
            selectItem(at: actualIndex)
        }
    }

    private func selectNextItem() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let nextIndex = (currentIndex + 1 + 5) % 5
            let actualIndex = min(nextIndex, items.count - 1)
            selectItem(at: actualIndex)
        }
    }
    
    private func selectPreviousItem2() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let previousIndex = currentIndex - 1
            let actualIndex = max(previousIndex, 0)
            selectItem(at: actualIndex)
        }
    }

    private func selectNextItem2() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let nextIndex = currentIndex + 1
            let actualIndex = min(nextIndex, items.count - 1)
            selectItem(at: actualIndex)
        }
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

