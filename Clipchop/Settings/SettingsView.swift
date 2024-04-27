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
    @State var selectedNavigation: Navigation = .general
    
    enum Navigation {
        case general
        case clipboard
        case syncing
        case about
    }
    
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
                .foregroundStyle(.tertiary)
                .imageScale(.large)
                .frame(width: 24)
            
            Text(titleKey)
                .font(.title3)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 7.5)
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedNavigation) {
                navigationLink("General") {
                    Image(systemSymbol: .gearshape)
                } content: {
                    GeneralSettingsPage()
                }
                .tag(Navigation.general)
                
                navigationLink("Clipboard") {
                    Image(systemSymbol: .clipboard)
                } content: {
                    SyncingSettingsPage()
                }
                .tag(Navigation.clipboard)
                
                navigationLink("Syncing") {
                    Image(systemSymbol: .checkmarkIcloud)
                } content: {
                    SyncingSettingsPage()
                }
                .tag(Navigation.syncing)
                
                navigationLink("About") {
                    Image(systemSymbol: .infoCircle)
                } content: {
                    AboutSettingsPage()
                }
                .tag(Navigation.about)
            }
            .navigationSplitViewColumnWidth(180)
        } detail: {
            Spacer()
                .navigationSplitViewColumnWidth(550)
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
