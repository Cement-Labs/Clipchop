//
//  BeginningHelloPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningHelloPage: View {
    var body: some View {
        VStack {
            Image(nsImage: AppIcon.currentAppIcon.image)
            
            Text(Bundle.main.appName)
                .font(.title)
                .bold()
        }
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    BeginningHelloPage()
}
