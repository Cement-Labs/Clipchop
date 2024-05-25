//
//  BeginningPermissionsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/22.
//

import SwiftUI

struct BeginningPermissionsPage: View {
    @Environment(\.canContinue) var canContinue
    
    var body: some View {
        VStack {
            VStack {
                Image(systemSymbol: .lock)
                    .imageScale(.large)
                    .padding()
                
                Text("Permissions")
            }
            .font(.title)
            .bold()
            .frame(maxHeight: .infinity)
            
            Form {
                PermissionsSection()
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
        }
        .padding()
        .frame(width: BeginningViewController.size.width)
        .frame(maxHeight: .infinity)
        
        .onChange(of: PermissionsManager.remaining, initial: true) { old, new in
            canContinue(new == 0)
        }
    }
}

#Preview {
    BeginningPermissionsPage()
}
