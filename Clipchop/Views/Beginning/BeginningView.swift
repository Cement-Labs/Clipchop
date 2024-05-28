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
                
                if !roaming.hasHext {
                    Button {
                        NSApp.openSettings()
                        viewController?.close()
                    } label: {
                        Text("Open Settings…")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .controlSize(.extraLarge)
                    .buttonStyle(.borderless)
                }
                
                RoamingButton(canHover: canRoamingContinue) {
                    if roaming.hasHext {
                        next()
                    } else {
                        viewController?.close()
                    }
                } label: {
                    HStack {
                        if roaming.hasHext {
                            Text("Continue")
                            Image(systemSymbol: .arrowForward)
                        } else {
                            Text("Start Using \(Bundle.main.appName)")
                        }
                    }
                    .font(.title3)
                    .blendMode(.luminosity)
                    .fixedSize()
                } background: {
                    Rectangle()
                        .if(canRoamingContinue) { view in
                            view.fill(.accent)
                        } falseExpression: { view in
                            view.fill(.placeholder)
                        }
                        .clipShape(.buttonBorder)
                }
                .disabled(!canRoamingContinue)
                
                .tint(.white)
                .shadow(color: canRoamingContinue ? .accent.opacity(0.25) : .clear, radius: 15, y: 7)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                Spacer()
                
                HStack {
                    if roaming.hasPrevious && roaming.hasHext {
                        RoamingButton {
                            previous()
                        } label: {
                            HStack {
                                Image(systemSymbol: .arrowBackward)
                                Text("Back")
                            }
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .fixedSize()
                        } background: {
                            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                                .clipShape(.buttonBorder)
                        }
                    }
                    
                    Spacer()
                    
                    if !canRoamingContinue && roaming.hasHext {
                        RoamingButton {
                            next()
                        } label: {
                            HStack {
                                Text("Skip")
                                Image(systemSymbol: .arrowUturnForward)
                            }
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .fixedSize()
                        } background: {
                            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                                .clipShape(.buttonBorder)
                        }
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
    }
}
