//
//  BeginningHelloPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningHelloPage: View {
    var body: some View {
        Group {
            Text("Hello")
        }
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
        .background(.red)
    }
}

#Preview {
    BeginningHelloPage()
}
