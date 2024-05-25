//
//  BeginningView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningView: View {
    enum Roaming: Int, CaseIterable {
        case hello = 0
        case tutorial = 1
        case permissions = 2
        case shortcuts = 3
        case customization = 4
        
        var next: Self {
            Self(rawValue: self.rawValue + 1) ?? self
        }
        
        var hasHext: Bool {
            self.next != self
        }
        
        var previous: Self {
            Self(rawValue: self.rawValue - 1) ?? self
        }
        
        var hasPrevious: Bool {
            self.previous != self
        }
        
        var offsetY: CGFloat {
            -CGFloat(self.rawValue) * BeginningViewController.size.width
        }
    }
    
    @State var roaming: Roaming = .hello
    @State var canContinue: [Roaming: Bool] = [:]
    @State var isContinueButtonHovering = false
    
    var canRoamingContinue: Bool {
        canContinue[roaming] ?? true
    }
    
    func previous() {
        withAnimation {
            roaming = roaming.previous
        }
    }
    
    func next() {
        withAnimation {
            roaming = roaming.next
        }
    }
    
    func canContinueCallback(roaming: Roaming, _ canContinue: Bool) {
        self.canContinue[roaming] = canContinue
    }
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal) {
                HStack(alignment: .center, spacing: 0) {
                    BeginningHelloPage()
                        .environment(\.canContinue, { canContinueCallback(roaming: .hello, $0) })
                    
                    BeginningTutorialPage()
                        .environment(\.canContinue, { canContinueCallback(roaming: .tutorial, $0) })
                    
                    BeginningPermissionsPage()
                        .environment(\.canContinue, { canContinueCallback(roaming: .permissions, $0) })
                    
                    BeginningShortcutsPage()
                        .environment(\.canContinue, { canContinueCallback(roaming: .shortcuts, $0) })
                    
                    BeginningCustomizationPage()
                        .environment(\.canContinue, { canContinueCallback(roaming: .customization, $0) })
                }
                .offset(x: roaming.offsetY)
                
                .environment(\.hasTitle, false)
            }
            .scrollIndicators(.never)
            .scrollDisabled(true)
            
            VStack {
                Spacer()
                
                Button {
                    next()
                } label: {
                    HStack {
                        if roaming.hasHext {
                            Text("Continue")
                            Image(systemSymbol: .arrowForward)
                        } else {
                            Text("Start Using")
                            Image(.appSymbol)
                        }
                    }
                    .padding()
                    .font(.title3)
                    .blendMode(.luminosity)
                }
                .background {
                    Rectangle()
                        .if(condition: canRoamingContinue) { view in
                            view.fill(.accent)
                        } falseExpression: { view in
                            view.fill(.placeholder)
                        }
                        .clipShape(.buttonBorder)
                }
                .disabled(!canRoamingContinue)
                .controlSize(.extraLarge)
                .buttonStyle(.borderless)
                .buttonBorderShape(.capsule)
                .tint(.white)
                .shadow(color: canRoamingContinue ? .accent.opacity(0.25) : .clear, radius: 15, y: 7)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .frame(width: BeginningViewController.size.width, height: BeginningViewController.size.height)
        .fixedSize()
    }
}
