//
//  BeginningTutorialPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningTutorialPage: View {
    var body: some View {
        Group {
            Text("Tutorial")
        }
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    BeginningTutorialPage()
}
