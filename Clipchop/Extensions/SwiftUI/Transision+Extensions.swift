//
//  Transision+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/25.
//

import SwiftUI

// https://stackoverflow.com/a/71599594/23452915
extension AnyTransition {
    static func rotate3D(angle: Angle) -> AnyTransition {
        AnyTransition.modifier(
            active: Rotate3DModifier(value: 1, angle: angle),
            identity: Rotate3DModifier(value: 0, angle: angle))
    }
}

struct Rotate3DModifier: ViewModifier {
    let value: Double
    let angle: Angle
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(1 - value * 0.25)
            .rotation3DEffect(.radians(angle.radians * value), axis: (x: 0, y: 1, z: 0))
            .opacity(1 - value)
    }
}
