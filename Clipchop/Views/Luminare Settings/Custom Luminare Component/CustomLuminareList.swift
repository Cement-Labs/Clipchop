//
//  CustomLuminareList.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/28.
//

import SwiftUI
import Luminare

struct ClickedOutsideFlagKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var clickedOutsideFlag: Bool {
        get { self[ClickedOutsideFlagKey.self] }
        set { self[ClickedOutsideFlagKey.self] = newValue }
    }
}

struct CurrentlyScrollingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var currentlyScrolling: Bool {
        get { self[CurrentlyScrollingKey.self] }
        set { self[CurrentlyScrollingKey.self] = newValue }
    }
}

import SwiftUI

public struct CustomLuminareList<ContentA, ContentB, ContentC, V, ID>: View where ContentA: View, ContentB: View, ContentC: View, V: Hashable, ID: Hashable {
    @Environment(\.tintColor) var tintColor
    @Environment(\.clickedOutsideFlag) var clickedOutsideFlag

    let header: LocalizedStringKey?
    @Binding var items: [V]
    @Binding var selection: Set<V>
    let addActionView: () -> ContentC
    let removeAction: () -> Void
    let content: (V) -> ContentA
    let emptyView: () -> ContentB

    @State private var firstItem: V?
    @State private var lastItem: V?
    let id: KeyPath<V, ID>

    let addText: LocalizedStringKey
    let removeText: LocalizedStringKey

    @State var canRefreshSelection = true
    let cornerRadius: CGFloat = 2
    let lineWidth: CGFloat = 1.5
    @State var eventMonitor: AnyObject?

    public init(
        _ header: LocalizedStringKey? = nil,
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        addActionView: @escaping () -> ContentC,
        removeAction: @escaping () -> Void,
        @ViewBuilder content: @escaping (V) -> ContentA,
        @ViewBuilder emptyView: @escaping () -> ContentB,
        id: KeyPath<V, ID>,
        addText: LocalizedStringKey,
        removeText: LocalizedStringKey
    ) {
        self.header = header
        self._items = items
        self._selection = selection
        self.addActionView = addActionView
        self.removeAction = removeAction
        self.content = content
        self.emptyView = emptyView
        self.id = id
        self.addText = addText
        self.removeText = removeText
    }

    public var body: some View {
        LuminareSection(header, disablePadding: true) {
            HStack(spacing: 2) {
                Menu(addText) {
                    addActionView()
                }

                Button(removeText) {
                    removeAction()
                }
                .buttonStyle(LuminareDestructiveButtonStyle())
                .disabled(selection.isEmpty)
            }
            .modifier(
                LuminareCroppedSectionItem(
                    isFirstChild: true,
                    isLastChild: false
                )
            )
            .padding(.vertical, 4)
            .padding(.bottom, 4)
            .padding([.top, .horizontal], 1)

            if items.isEmpty {
                emptyView()
                    .frame(minHeight: 50)
            } else {
                List(selection: $selection) {
                    ForEach(items, id: id) { item in
                        LuminareListItem(
                            items: $items,
                            selection: $selection,
                            item: item,
                            content: content,
                            firstItem: $firstItem,
                            lastItem: $lastItem,
                            canRefreshSelection: $canRefreshSelection
                        )
                    }
                    .onMove { indices, newOffset in
                        withAnimation(LuminareSettingsWindow.animation) {
                            items.move(fromOffsets: indices, toOffset: newOffset)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, -10)
                }
                .frame(height: CGFloat(items.count * 50))
                .padding(.top, 4)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .listStyle(.plain)
            }
        }
        .onChange(of: clickedOutsideFlag) { _, _ in
            withAnimation(LuminareSettingsWindow.animation) {
                selection = []
            }
        }
        .onChange(of: selection) { _, _ in
            processSelection()

            if selection.isEmpty {
                removeEventMonitor()
            } else {
                addEventMonitor()
            }
        }
        .onAppear {
            if !selection.isEmpty {
                addEventMonitor()
            }
        }
        .onDisappear {
            removeEventMonitor()
        }
    }

    func processSelection() {
        if selection.isEmpty {
            firstItem = nil
            lastItem = nil
        } else {
            firstItem = items.first(where: { selection.contains($0) })
            lastItem = items.last(where: { selection.contains($0) })
        }
    }

    func addEventMonitor() {
        if eventMonitor != nil {
            return
        }
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let kVK_Escape: CGKeyCode = 0x35

            if event.keyCode == kVK_Escape {
                withAnimation(LuminareSettingsWindow.animation) {
                    selection = []
                }
                return nil
            }
            return event
        } as? NSObject
    }

    func removeEventMonitor() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        eventMonitor = nil
    }
}

struct LuminareListItem<Content, V>: View where Content: View, V: Hashable {
    @Environment(\.tintColor) var tintColor
    @Environment(\.currentlyScrolling) var currentlyScrolling

    let item: V
    let content: (V) -> Content

    @Binding var items: [V]
    @Binding var selection: Set<V>

    @Binding var firstItem: V?
    @Binding var lastItem: V?
    @Binding var canRefreshSelection: Bool

    @State var isHovering = false

    let cornerRadius: CGFloat = 2
    let maxLineWidth: CGFloat = 1.5
    @State var lineWidth: CGFloat = .zero

    let maxTintOpacity: CGFloat = 0.15
    @State var tintOpacity: CGFloat = .zero

    init(
        items: Binding<[V]>,
        selection: Binding<Set<V>>,
        item: V,
        @ViewBuilder content: @escaping (V) -> Content,
        firstItem: Binding<V?>,
        lastItem: Binding<V?>,
        canRefreshSelection: Binding<Bool>
    ) {
        self._items = items
        self._selection = selection
        self.item = item
        self.content = content
        self._firstItem = firstItem
        self._lastItem = lastItem
        self._canRefreshSelection = canRefreshSelection
    }

    var body: some View {
        Color.clear
            .frame(height: 50)
            .overlay {
                content(item)
                    .environment(\.hoveringOverLuminareItem, isHovering)
            }
            .tag(item)
            .onHover { hover in
                guard !currentlyScrolling else { return }

                withAnimation(LuminareSettingsWindow.fastAnimation) {
                    isHovering = hover
                }
            }
            .background {
                ZStack {
                    getItemBorder()
                    getItemBackground()
                }
                .padding(.horizontal, 1)
                .padding(.leading, 1)
            }
            .overlay {
                if item != items.last {
                    VStack {
                        Spacer()
                        Divider()
                    }
                    .padding(.trailing, -0.5)
                }
            }
            .onChange(of: selection) { _, _ in
                guard canRefreshSelection else { return }
                DispatchQueue.main.async {
                    withAnimation(LuminareSettingsWindow.animation) {
                        tintOpacity = selection.contains(item) ? maxTintOpacity : .zero
                        lineWidth = selection.contains(item) ? maxLineWidth : .zero
                    }
                }
            }
            .onChange(of: currentlyScrolling) { _, _ in
                if currentlyScrolling {
                    withAnimation(LuminareSettingsWindow.fastAnimation) {
                        isHovering = false
                    }
                }
            }
    }

    @ViewBuilder func getItemBackground() -> some View {
        Group {
            tintColor()
                .opacity(tintOpacity)

            if isHovering {
                Rectangle()
                    .foregroundStyle(.quaternary.opacity(0.7))
                    .opacity((maxTintOpacity - tintOpacity) * (1 / maxTintOpacity))
            }
        }
    }

    @ViewBuilder func getItemBorder() -> some View {
        if isFirstInSelection(), isLastInSelection() {
            singleSelectionPart(isBottomOfList: item == items.last)
        } else if isFirstInSelection() {
            firstItemPart()
        } else if isLastInSelection() {
            lastItemPart(isBottomOfList: item == items.last)
        } else if selection.contains(item) {
            doubleLinePart()
        }
    }

    func isFirstInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex > 0,
           !selection.contains(items[firstIndex - 1]) {
            return true
        }

        return item == firstItem
    }

    func isLastInSelection() -> Bool {
        if let firstIndex = items.firstIndex(of: item),
           firstIndex < items.count - 1,
           !selection.contains(items[firstIndex + 1]) {
            return true
        }

        return item == lastItem
    }

    func firstItemPart() -> some View {
        VStack(spacing: 0) {
            singleSelectionPart(isBottomOfList: false)

            Rectangle()
//                .foregroundStyle(tintColor)
                .frame(maxWidth: .infinity)
                .frame(height: lineWidth / 2)
                .opacity(tintOpacity)
        }
    }

    func lastItemPart(isBottomOfList: Bool) -> some View {
        VStack(spacing: 0) {
            Rectangle()
//                .foregroundStyle(tintColor)
                .frame(maxWidth: .infinity)
                .frame(height: lineWidth / 2)
                .opacity(tintOpacity)

            singleSelectionPart(isBottomOfList: isBottomOfList)
        }
    }

    func doubleLinePart() -> some View {
        VStack(spacing: 0) {
            Rectangle()
//                .foregroundStyle(tintColor)
                .frame(maxWidth: .infinity)
                .frame(height: lineWidth / 2)
                .opacity(tintOpacity)

            singleSelectionPart(isBottomOfList: false)

            Rectangle()
//                .foregroundStyle(tintColor)
                .frame(maxWidth: .infinity)
                .frame(height: lineWidth / 2)
                .opacity(tintOpacity)
        }
    }

    func singleSelectionPart(isBottomOfList: Bool) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
//            .stroke(tintColor, lineWidth: lineWidth)
            .frame(maxWidth: .infinity)
            .frame(height: isBottomOfList ? 48.5 : 49)
            .opacity(tintOpacity)
    }
}

