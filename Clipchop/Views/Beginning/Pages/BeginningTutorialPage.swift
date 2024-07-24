//
//  BeginningTutorialPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningTutorialPage: View {
    @Environment(\.namespace) private var namespace
    @Environment(\.isVisible) private var isVisible
    
    var body: some View {
        Group {
            VStack {
                if isVisible {
                    Image(systemSymbol: .lightbulb)
                        .imageScale(.large)
                        .padding()
                        .matchedGeometryEffect(id: "flip", in: namespace!)
                        .transition(.rotate3D(angle: .degrees(65)).combined(with: .scale).combined(with: .opacity))
                }
                
                Text("Tutorial")
            }
            .font(.title)
            .bold()
            .frame(maxHeight: .infinity)
        }
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    BeginningTutorialPage()
}
