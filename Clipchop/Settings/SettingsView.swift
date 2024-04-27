//
//  SettingsView.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import SFSafeSymbols

struct SettingsView: View {
    @State var selectedNavigation: Int = 0
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedNavigation) {
                NavigationLink {
                    GeneralSettingsPage()
                } label: {
                    Image(systemSymbol: .gearshape)
                    Text("General")
                }
                .tag(0)
                
                NavigationLink {
                    AboutSettingsPage()
                } label: {
                    Image(systemSymbol: .infoCircle)
                    Text("About")
                }
                .tag(1)
            }
            .toolbar(removing: .sidebarToggle)
        } detail: {
        }
        .navigationTitle(Bundle.main.appName)
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            Button("Quit") {
                
            }
            .controlSize(.extraLarge)
        }
    }
}

#Preview {
    SettingsView()
}
