//
//  BeginningView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI
import Defaults

struct BeginningView: View {
    enum Roaming: Int, CaseIterable {
        case hello = 0
        case tutorial = 1
        case permissions = 2
        case shortcuts = 3
        case customization = 4
        case allSet = 5
        
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
    
    @Default(.preferredColorScheme) var preferredColorScheme
    
    @Namespace var namespace
    
    @State var roaming: Roaming = .hello
    @State var canContinue: [Roaming: Bool] = [:]
    @State var isContinueButtonHovering = false
    @State var isFinished = false
    
    @Environment(\.viewController) var viewController
    
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
                        .environment(\.isVisible, roaming == .hello)
                    
                    BeginningTutorialPage()
                        .environment(\.canContinue, { canContinueCallback(roaming: .tutorial, $0) })
                        .environment(\.isVisible, roaming == .tutorial)
                    
                    BeginningPermissionsPage()
                        .environment(\.canContinue, { canContinueCallback(roaming: .permissions, $0) })
                        .environment(\.isVisible, roaming == .permissions)
                    
                    BeginningShortcutsPage()
                        .environment(\.canContinue, { canContinueCallback(roaming: .shortcuts, $0) })
                        .environment(\.isVisible, roaming == .shortcuts)
                    
                    BeginningCustomizationPage()
                        .environment(\.canContinue, { canContinueCallback(roaming: .customization, $0) })
                        .environment(\.isVisible, roaming == .customization)
                    
                    BeginningAllSetPage()
                        .environment(\.canContinue, { canContinueCallback(roaming: .allSet, $0) })
                        .environment(\.isVisible, roaming == .allSet)
                }
                .offset(x: roaming.offsetY)
                
                .environment(\.hasTitle, false)
                .environment(\.namespace, namespace)
            }
            .scrollIndicators(.never)
            .scrollDisabled(true)
            
            VStack {
                Spacer()
                
                // With animation
                if !roaming.hasHext {
                    Button {
                        NSApp.openSettings()
                        viewController?.close()
                    } label: {
                        Text("Open Settings")
                            .padding()
                            .font(.title3)
                            .blendMode(.luminosity)
                    }
                    .controlSize(.extraLarge)
                    .buttonStyle(.borderless)
                    .buttonBorderShape(.capsule)
                }
                
                Button {
                    // Without animation
                    if !isFinished {
                        next()
                    } else {
                        viewController?.close()
                    }
                } label: {
                    HStack {
                        if !isFinished {
                            Text("Continue")
                            Image(systemSymbol: .arrowForward)
                        } else {
                            Text("Start Using \(Bundle.main.appName)")
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
                .scaleEffect(isContinueButtonHovering && canRoamingContinue ? 1.05 : 1)
                
                .controlSize(.extraLarge)
                .buttonStyle(.borderless)
                .buttonBorderShape(.capsule)
                
                .tint(.white)
                .shadow(color: canRoamingContinue ? .accent.opacity(0.25) : .clear, radius: 15, y: 7)
                
                .onHover { isHovering in
                    withAnimation {
                        isContinueButtonHovering = isHovering
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .preferredColorScheme(preferredColorScheme.colorScheme)
        .ignoresSafeArea()
        .frame(width: BeginningViewController.size.width, height: BeginningViewController.size.height)
        .fixedSize()
        
        .onChange(of: roaming) { old, new in
            isFinished = !new.hasHext
        }
    }
}
