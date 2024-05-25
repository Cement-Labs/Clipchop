//
//  EnvironmentValues+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/23.
//

import SwiftUI

extension EnvironmentValues {
    var hasTitle: Bool {
        get { self[HasTitleEnvironmentKey.self] }
        set { self[HasTitleEnvironmentKey.self] = newValue }
    }
    
    var canContinue: (Bool) -> Void {
        get { self[CanContinueEnvironmentKey.self] }
        set { self[CanContinueEnvironmentKey.self] = newValue }
    }
    
    var viewController: ViewController? {
        get { self[ViewControllerEnvironmentKey.self] }
        set { self[ViewControllerEnvironmentKey.self] = newValue }
    }
}

struct HasTitleEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = true
}

struct CanContinueEnvironmentKey: EnvironmentKey {
    static var defaultValue: (Bool) -> Void = { _ in }
}

struct ViewControllerEnvironmentKey: EnvironmentKey {
    static var defaultValue: ViewController?
}
