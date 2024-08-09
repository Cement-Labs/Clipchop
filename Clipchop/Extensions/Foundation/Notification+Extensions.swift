//
//  Notification+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/25.
//

import Foundation

extension Notification.Name {
    static let didClip = Self("didClip")
    static let didPaste = Self("didPaste")
    // ClipHistory View expansion notification
}

extension Notification.Name {
    @discardableResult
    func onReceive(object: Any? = nil, using: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(
            forName: self,
            object: object,
            queue: .main,
            using: using
        )
    }
    
    func post(object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: self, object: object, userInfo: userInfo)
    }
}

extension Notification.Name {
    static let panelDidClose = Notification.Name("panelDidClose")
    static let panelDidOpen = Notification.Name("panelDidOpen")
}

