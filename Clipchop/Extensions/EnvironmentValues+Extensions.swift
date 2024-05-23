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
    
    var navigateToNext: () -> Void {
        get { self[NavigateToNextEnvironmentKey.self] }
        set { self[NavigateToNextEnvironmentKey.self] = newValue }
    }
    
    var navigateToPrevious: () -> Void {
        get { self[NavigateToPreviousEnvironmentKey.self] }
        set { self[NavigateToPreviousEnvironmentKey.self] = newValue }
    }
}

struct HasTitleEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = true
}

struct NavigateToNextEnvironmentKey: EnvironmentKey {
    static var defaultValue: () -> Void = {}
}

struct NavigateToPreviousEnvironmentKey: EnvironmentKey {
    static var defaultValue: () -> Void = {}
}
