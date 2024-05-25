//
//  BeginningAllSetPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/25.
//

import SwiftUI

struct BeginningAllSetPage: View {
    @Environment(\.namespace) var namespace
    @Environment(\.isVisible) var isVisible
    
    var body: some View {
        VStack {
            if isVisible {
                Image(nsImage: AppIcon.currentAppIcon.image)
                    .matchedGeometryEffect(id: "flip", in: namespace!)
                    .transition(.blurReplace.combined(with: .scale(0.75)))
            }
            
            Text("You're All Set!").foregroundStyle(.accent)
        }
        .font(.title)
        .bold()
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    BeginningAllSetPage()
}
