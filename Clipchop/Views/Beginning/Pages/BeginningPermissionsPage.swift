//
//  BeginningPermissionsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningPermissionsPage: View {
    @Environment(\.canContinue) var canContinue
    @Environment(\.namespace) var namespace
    @Environment(\.isVisible) var isVisible
    
    var body: some View {
        VStack {
            VStack {
                if isVisible {
                    Image(systemSymbol: .lock)
                        .imageScale(.large)
                        .padding()
                        .matchedGeometryEffect(id: "flip", in: namespace!)
                        .transition(.rotate3D(angle: .degrees(65)).combined(with: .scale).combined(with: .opacity))
                }
                
                Text("Permissions")
            }
            .font(.title)
            .bold()
            .frame(height: 200)
            
            Form {
                PermissionsSection()
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
        }
        .padding()
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
        
#if !DEBUG
        .onChange(of: PermissionsManager.remaining, initial: true) { old, new in
            canContinue(new == 0)
        }
#endif
    }
}

#Preview {
    BeginningPermissionsPage()
}
