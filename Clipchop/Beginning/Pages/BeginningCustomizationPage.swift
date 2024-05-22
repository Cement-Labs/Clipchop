//
//  BeginningCustomizationPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningCustomizationPage: View {
    var body: some View {
        Group {
            Text("Customization")
        }
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    BeginningCustomizationPage()
}
