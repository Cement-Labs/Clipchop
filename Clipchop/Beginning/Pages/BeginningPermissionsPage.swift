//
//  BeginningPermissionsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningPermissionsPage: View {
    var body: some View {
        Group {
            Text("Permissions")
        }
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    BeginningPermissionsPage()
}
