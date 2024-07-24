//
//  View+Extensions.swift
//  Dial
//
//  Created by KrLite on 2024/3/23.
//

import SwiftUI
import SwiftUIIntrospect

extension View {
    func or(_ condition: Bool, _ another: () -> Self) -> Self {
        condition ? another() : self
    }
    
    @ViewBuilder
    func orSomeView(_ condition: Bool, _ another: () -> some View) -> some View {
        if condition {
            another()
        } else {
            self
        }
    }
    
    @ViewBuilder
    func `if`(
        _ condition: Bool,
        trueExpression: (Self) -> some View,
        falseExpression: (Self) -> some View
    ) -> some View {
        if condition {
            trueExpression(self)
        } else {
            falseExpression(self)
        }
    }
    
    @ViewBuilder
    func `if`(
        _ condition: Bool,
        expression: (Self) -> some View
    ) -> some View {
        `if`(condition, trueExpression: expression) { view in
            view
        }
    }
    
    @ViewBuilder
    func possibleKeyboardShortcut(
        _ key: KeyEquivalent?,
        modifiers: EventModifiers = .command,
        localization: KeyboardShortcut.Localization = .automatic
    ) -> some View {
        if let key {
            self.keyboardShortcut(key, modifiers: modifiers, localization: localization)
        } else {
            self
        }
    }
    
    // https://github.com/MrKai77/Loop
    func onReceive(
        _ name: Notification.Name,
        center: NotificationCenter = .default,
        object: AnyObject? = nil,
        perform action: @escaping (Notification) -> Void
    ) -> some View {
        self.onReceive(
            center.publisher(for: name, object: object),
            perform: action
        )
    }
    
    @ViewBuilder
    func navigationSplitViewCollapsingDisabled() -> some View {
        // Completely prevents the sidebar from collapsing
        self.introspect(.navigationSplitView, on: .macOS(.v14), scope: .ancestor) { splitView in
            (splitView.delegate as? NSSplitViewController)?.splitViewItems.forEach { $0.canCollapse = false }
        }
    }
}

extension View {
    func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        Clipchop.log(self, items, separator: separator, terminator: terminator)
    }
}

extension View {
    @ViewBuilder
    func applyMatchedGeometryEffect(if condition: Bool, id: AnyHashable, namespace: Namespace.ID) -> some View {
        if condition {
            self.matchedGeometryEffect(id: id, in: namespace, properties: .frame, anchor: .center, isSource: true)
        } else {
            self
        }
    }
}


extension View {
    func applyKeyboardShortcut(_ keyboardShortcut: String, modifier: EventModifiers) -> some View {
        if keyboardShortcut != "none" {
            return AnyView(self.keyboardShortcut(KeyEquivalent(keyboardShortcut.first!), modifiers: modifier))
        } else {
            return AnyView(self)
        }
    }
}
