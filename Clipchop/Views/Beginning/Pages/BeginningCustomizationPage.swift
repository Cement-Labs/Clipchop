//
//  BeginningCustomizationPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningCustomizationPage: View {
    @Environment(\.namespace) var namespace
    @Environment(\.isVisible) var isVisible
    
    var body: some View {
        VStack {
            VStack {
                if isVisible {
                    Image(systemSymbol: .pencilAndOutline)
                        .imageScale(.large)
                        .padding()
                        .matchedGeometryEffect(id: "flip", in: namespace!)
                        .transition(.rotate3D(angle: .degrees(65)).combined(with: .scale).combined(with: .opacity))
                }
                
                Text("Customization")
            }
            .font(.title)
            .bold()
            .frame(height: 200)
            
            Form {
                AppearanceSection()
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
        }
        .padding()
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    BeginningCustomizationPage()
}
