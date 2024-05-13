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
    
    @Binding var isWindowInitialized: Bool
    
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
                }
                .tag(Navigation.general)
                
                navigationLink("Customization") {
                    Image(systemSymbol: .pencilAndOutline)
                } content: {
                    CustomizationSettingsPage()
                }
                .tag(Navigation.customization)
                
                navigationLink("Clipboard") {
                    Image(systemSymbol: .clipboard)
                } content: {
                    SyncingSettingsPage()
                }
                .tag(Navigation.clipboard)
                
                navigationLink("Excluded Apps") {
                    Image(systemSymbol: .lockAppDashed)
                } content: {
                    ExcludedAppsSettingsPage()
                        .environmentObject(apps)
                }
                .tag(Navigation.excludedApps)
                
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
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            Spacer()
                .navigationSplitViewColumnWidth(min: 350, ideal: 750)
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
        
        // An intermediate view to hide the ugly window toolbar transition
        .orSomeView(condition: !isWindowInitialized) {
            Image(.appSymbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 64)
                .foregroundStyle(.placeholder)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SettingsView(isWindowInitialized: .constant(true))
}
