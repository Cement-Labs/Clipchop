//
//  SettingsView.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import SFSafeSymbols

@ViewBuilder
func section(
    _ titleKey: LocalizedStringKey,
    @ViewBuilder content: () -> some View
) -> some View {
    Section {
        content()
    } header: {
        HStack {
            Text(titleKey)
                .bold()
                .font(.title)
            
            Spacer()
        }
    }
    .padding(2)
}

func withCaption(
    _ descriptionKey: LocalizedStringKey,
    condition: Bool = true,
    @ViewBuilder content: () -> some View
) -> some View {
    VStack(alignment: .leading) {
        content()
        
        if condition {
            Text(descriptionKey)
                .font(.caption)
                .foregroundStyle(.placeholder)
        }
    }
}

struct SettingsView: View {
    @State var selectedNavigation: Int = 0
    
    @ViewBuilder
    func navigationLink(
        _ titleKey: LocalizedStringKey,
        image: () -> Image,
        @ViewBuilder content: () -> some View
    ) -> some View {
        NavigationLink {
            content()
        } label: {
            image()
                .foregroundStyle(.secondary)
                .imageScale(.large)
            Text(titleKey)
                .font(.title3)
        }
        .padding(6)
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedNavigation) {
                navigationLink("General") {
                    Image(systemSymbol: .gearshape)
                } content: {
                    GeneralSettingsPage()
                }
                .tag(0)
                
                navigationLink("About") {
                    Image(systemSymbol: .infoCircle)
                } content: {
                    AboutSettingsPage()
                }
                .tag(1)
            }
            .toolbar(removing: .sidebarToggle)
            .navigationSplitViewColumnWidth(150)
        } detail: {
            Spacer()
                .navigationSplitViewColumnWidth(600)
        }
        .navigationTitle(Bundle.main.appName)
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            Button("Quit") {
                quit()
            }
            .controlSize(.extraLarge)
        }
    }
}

#Preview {
    SettingsView()
}
