//
//  Wiggle.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/26.
//

import SwiftUI

struct Wiggle: ViewModifier {
    @Binding var isAnimating: Bool
    @State private var angle: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(angle))
            .onAppear {
                if isAnimating {
                    startWiggling()
                }
            }
            .onChange(of: isAnimating) { newValue, _ in
                if newValue {
                    stopWiggling()
                } else {
                    startWiggling()
                }
            }
    }
    
    private func startWiggling() {
        withAnimation(Animation.linear(duration: 0.1).repeatForever(autoreverses: true)) {
            angle = 4
        }
    }
    
    private func stopWiggling() {
        withAnimation(Animation.linear(duration: 0.1)) {
            angle = 0
        }
    }
}

extension View {
    func wiggle(isAnimating: Binding<Bool>) -> some View {
        self.modifier(Wiggle(isAnimating: isAnimating))
    }
}
