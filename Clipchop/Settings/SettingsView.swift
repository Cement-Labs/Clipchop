//
//  SettingsView.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import SFSafeSymbols

@ViewBuilder
func description(@ViewBuilder label: () -> some View) -> some View {
    label()
        .font(.caption)
        .foregroundStyle(.placeholder)
}

@ViewBuilder
func withCaption(
    condition: Bool = true,
    @ViewBuilder content: () -> some View,
    @ViewBuilder label: () -> Text
) -> some View {
    VStack(alignment: .leading) {
        content()
        
        if condition {
            description {
                label()
            }
        }
    }
}

@ViewBuilder
func withCaption(
    _ descriptionKey: LocalizedStringKey,
    condition: Bool = true,
    @ViewBuilder content: () -> some View
) -> some View {
    withCaption(condition: condition) {
        content()
    } label: {
        Text(descriptionKey)
    }
}

struct SettingsView: View {
    @State var selectedNavigation: Navigation = .general
    @State var apps = Apps()
    
    enum Navigation {
        case general
        case customization
        case clipboard
        case excludedApps
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
                        .padding()
                }
                .tag(Navigation.general)
                
                navigationLink("Customization") {
                    Image(systemSymbol: .pencilAndOutline)
                } content: {
                    CustomizationSettingsPage()
                        .padding()
                }
                .tag(Navigation.customization)
                
                navigationLink("Clipboard") {
                    Image(systemSymbol: .clipboard)
                } content: {
                    SyncingSettingsPage()
                        .padding()
                }
                .tag(Navigation.clipboard)
                
                navigationLink("Excluded Apps") {
                    Image(systemSymbol: .lockAppDashed)
                } content: {
                    ExcludedAppsSettingsPage()
                        .padding()
                        .environmentObject(apps)
                }
                .tag(Navigation.excludedApps)
                
                navigationLink("Syncing") {
                    Image(systemSymbol: .checkmarkIcloud)
                } content: {
                    SyncingSettingsPage()
                        .padding()
                }
                .tag(Navigation.syncing)
                
                navigationLink("About") {
                    Image(systemSymbol: .infoCircle)
                } content: {
                    AboutSettingsPage()
                        .padding()
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
        .formStyle(.grouped)
    }
}

#Preview {
    SettingsView()
}
