//
//  BeginningHelloPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningHelloPage: View {
    @Environment(\.namespace) private var namespace
    @Environment(\.isVisible) private var isVisible
    
    var body: some View {
        VStack {
            if isVisible {
                Image(nsImage: AppIcon.currentAppIcon.image)
                    .matchedGeometryEffect(id: "flip", in: namespace!)
                    .transition(.blurReplace.combined(with: .scale(0.75)))
            }
            
            Text("Welcome to \(Text(Bundle.main.appName).foregroundStyle(.accent))")
        }
        .font(.title)
        .bold()
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    BeginningHelloPage()
}
