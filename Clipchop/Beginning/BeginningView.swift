//
//  BeginningView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningView: View {
    var body: some View {
        Group {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .ignoresSafeArea()
        .frame(width: BeginningViewController.size.width, height: BeginningViewController.size.height)
        .fixedSize()
    }
}
