//
//  View+Extensions.swift
//  Dial
//
//  Created by KrLite on 2024/3/23.
//

import SwiftUI

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
}

extension View {
    func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        Clipchop.log(self, items, separator: separator, terminator: terminator)
    }
}
