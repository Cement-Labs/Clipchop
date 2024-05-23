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
        case permissions = 1
        case tutorial = 2
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
    
    @State var selectedRoaming: Roaming = .hello
    
    func previous() {
        withAnimation {
            selectedRoaming = selectedRoaming.previous
        }
    }
    
    func next() {
        withAnimation {
            selectedRoaming = selectedRoaming.next
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal) {
                HStack(alignment: .center, spacing: 0) {
                    BeginningHelloPage()
                    
                    BeginningPermissionsPage()
                    
                    BeginningTutorialPage()
                    
                    BeginningShortcutsPage()
                    
                    BeginningCustomizationPage()
                }
                .offset(x: selectedRoaming.offsetY)
                
                .environment(\.hasTitle, false)
                .environment(\.navigateToNext, next)
                .environment(\.navigateToPrevious, previous)
            }
            .scrollIndicators(.never)
            .scrollDisabled(true)
            
            VStack {
                Spacer()
                
                HStack {
                    if selectedRoaming.hasPrevious {
                        Button {
                            previous()
                        } label: {
                            HStack {
                                Image(systemSymbol: .chevronBackward)
                                
                                Image(systemSymbol: .command)
                                    .foregroundStyle(.placeholder)
                            }
                            .padding()
                        }
                        .background {
                            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                                .clipShape(.capsule)
                        }
                        .keyboardShortcut(.leftArrow, modifiers: .command)
                    }
                    
                    Spacer()
                    
                    if selectedRoaming.hasHext {
                        Button {
                            next()
                        } label: {
                            HStack {
                                Image(systemSymbol: .command)
                                    .foregroundStyle(.placeholder)
                                
                                Image(systemSymbol: .chevronForward)
                            }
                            .padding()
                        }
                        .background {
                            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                                .clipShape(.capsule)
                        }
                        .keyboardShortcut(.rightArrow, modifiers: .command)
                    }
                }
                .bold()
                .controlSize(.extraLarge)
                .buttonStyle(.borderless)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .frame(width: BeginningViewController.size.width, height: BeginningViewController.size.height)
        .fixedSize()
    }
}
