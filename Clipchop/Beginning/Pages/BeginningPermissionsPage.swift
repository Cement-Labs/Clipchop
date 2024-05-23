//
//  BeginningPermissionsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningPermissionsPage: View {
    var body: some View {
        VStack {
            VStack {
                Text("Permissions")
                    .font(.title)
                    .bold()
            }
            .frame(maxHeight: .infinity)
            
            Form {
                PermissionsSection(hasTitle: false)
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
    BeginningPermissionsPage()
}
