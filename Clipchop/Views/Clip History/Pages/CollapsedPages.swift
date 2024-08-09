//
//  CollapsedPages.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/7.
//

import SwiftUI
import Defaults

struct CollapsedPages: View {
    
    @FetchRequest(fetchRequest: ClipboardHistory.all(), animation: .snappy(duration: 0.75)) private var items
    var animationNamespace: Namespace.ID
    
    @State private var selectedIndex: Int? = nil
    
    @State private var eventLeft: Any?
    @State private var eventRight: Any?
    @State private var eventScroll: Any?
    
    @State private var scrollOffset: CGFloat = 0
    @State private var proxy: ScrollViewProxy?

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
            ScrollViewReader { scrollViewProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: Defaults[.displayMore] ? 16 : 12) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            if Defaults[.hideTag] {
                                CardPreviewView_2(
                                    item: item,
                                    isSelected: isSelectedBinding(for: index),
                                    keyboardShortcut: getKeyboardShortcut(for: index)
                                )
                                .id(index)
                                .environmentObject(apps)
                                .applyMatchedGeometryEffect(if: index < 6, id: item.id, namespace: animationNamespace)
                            } else {
                                CardPreviewView(
                                    item: item,
                                    isSelected: isSelectedBinding(for: index),
                                    keyboardShortcut: getKeyboardShortcut(for: index)
                                )
                                .id(index)
                                .environmentObject(apps)
                                .applyMatchedGeometryEffect(if: index < 6, id: item.id, namespace: animationNamespace)
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
                .onAppear {
                    setupEventMonitors()
                    proxy = scrollViewProxy
                }
                .onDisappear {
                    cleanupEventMonitors()
                }
                .onReceive(.panelDidClose) { _ in
                    selectedIndex = nil
                    scrollOffset = 0
                    if let proxy = proxy {
                        proxy.scrollTo(Int(scrollOffset), anchor: .center)
                    }
                }
            }
        }
        .frame(width: Defaults[.displayMore] ? 700 : 500, height: Defaults[.displayMore] ? 140 : 100)
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
        
        eventScroll = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
            let deltaY = event.scrollingDeltaY
            
            let horizontalScrollAmount = deltaY / 5.0
            
            guard abs(horizontalScrollAmount) > 0.5 else { return event }

            let itemWidth: CGFloat = Defaults[.displayMore] ? 116 : 112
            let totalContentWidth = CGFloat(items.count) * itemWidth

            if let proxy = proxy {
               
                withAnimation {
                    scrollOffset = max(0, min(scrollOffset + horizontalScrollAmount, totalContentWidth))
                    proxy.scrollTo(Int(scrollOffset), anchor: .center)
                }
            }
            return event
        }
    }
    
    private func cleanupEventMonitors() {
        // Remove event monitors to avoid leaks
        if let monitor = eventRight {
            NSEvent.removeMonitor(monitor)
            eventRight = nil
        }
        if let monitor = eventLeft {
            NSEvent.removeMonitor(monitor)
            eventLeft = nil
        }
        if let monitor = eventScroll {
            NSEvent.removeMonitor(monitor)
            eventScroll = nil
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
            let itemCount = min(items.count, 5)
            let previousIndex = (currentIndex - 1 + itemCount) % itemCount
            selectItem(at: previousIndex)
        }
    }

    private func selectNextItem() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let itemCount = min(items.count, 5)
            let nextIndex = (currentIndex + 1) % itemCount
            selectItem(at: nextIndex)
        }
    }
    
    private func selectPreviousItem2() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let itemCount = items.count
            
            if itemCount == 0 { return }
            
            let previousIndex = currentIndex > 0 ? currentIndex - 1 : 0
            selectItem(at: previousIndex)
            if let newIndex = selectedIndex, let proxy = proxy  {
                withAnimation {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }

    private func selectNextItem2() {
        if selectedIndex == nil {
            selectItem(at: 0)
        } else {
            guard let currentIndex = selectedIndex else { return }
            let itemCount = items.count
            
            if itemCount == 0 { return }
            
            let nextIndex = currentIndex < itemCount - 1 ? currentIndex + 1 : itemCount - 1
            selectItem(at: nextIndex)
            if let newIndex = selectedIndex, let proxy = proxy  {
                withAnimation {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
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

