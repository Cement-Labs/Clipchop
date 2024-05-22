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
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    BeginningHelloPage()
                    
                    BeginningPermissionsPage()
                    
                    BeginningTutorialPage()
                    
                    BeginningShortcutsPage()
                    
                    BeginningCustomizationPage()
                }
                .offset(x: selectedRoaming.offsetY)
            }
            .scrollIndicators(.never)
            .scrollDisabled(true)
            
            HStack {
                if selectedRoaming.hasPrevious {
                    Button {
                        withAnimation {
                            selectedRoaming = selectedRoaming.previous
                        }
                    } label: {
                        Image(systemSymbol: .chevronBackward)
                            .padding()
                    }
                    .background {
                        VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                            .clipShape(.circle)
                    }
                }
                
                Spacer()
                
                if selectedRoaming.hasHext {
                    Button {
                        withAnimation {
                            selectedRoaming = selectedRoaming.next
                        }
                    } label: {
                        Image(systemSymbol: .chevronForward)
                            .padding()
                    }
                    .background {
                        VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                            .clipShape(.circle)
                    }
                }
            }
            .padding()
            .bold()
            .controlSize(.extraLarge)
            .buttonStyle(.borderless)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .frame(width: BeginningViewController.size.width, height: BeginningViewController.size.height)
        .fixedSize()
    }
}
