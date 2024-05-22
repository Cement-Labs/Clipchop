//
//  SettingsView.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import SFSafeSymbols
import Defaults

@ViewBuilder
func description(@ViewBuilder label: () -> some View) -> some View {
    label()
        .font(.caption)
        .foregroundStyle(.secondary)
}

@ViewBuilder
func withCaption(
    condition: Bool = true,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> some View,
    @ViewBuilder caption: () -> some View
) -> some View {
    VStack(alignment: .leading, spacing: spacing) {
        content()
        
        if condition {
            description {
                caption()
            }
        }
    }
}

@ViewBuilder
func withCaption(
    _ descriptionKey: LocalizedStringKey,
    condition: Bool = true,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> some View
) -> some View {
    withCaption(condition: condition, spacing: spacing) {
        content()
    } caption: {
        Text(descriptionKey)
    }
}

@ViewBuilder
func listEmbeddedForm(formStyle: some FormStyle = .grouped,@ViewBuilder content: () -> some View) -> some View {
    List {
        Form {
            content()
        }
        .formStyle(formStyle)
        
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .ignoresSafeArea()
    }
}

@ViewBuilder
func previewSection(content: () -> some View) -> some View {
    previewPage {
        Form {
            content()
        }
    }
}

@ViewBuilder
func previewPage(content: () -> some View) -> some View {
    content()
        .formStyle(.grouped)
}

struct SettingsView: View {
    @State var selectedNavigation: Navigation = .general
    @State var apps = InstalledApps()
    
    @Binding var isWindowInitialized: Bool
    
    enum Navigation {
        case general
        case customization
        case clipboard
        case excludedApps
        case syncing
        case about
        
#if DEBUG
        case test
#endif
    }
    
    @ViewBuilder
    func navigationEntry(
        _ titleKey: LocalizedStringKey,
        image: () -> Image
    ) -> some View {
        HStack {
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
                navigationEntry("General") {
                    Image(systemSymbol: .gearshape)
                }
                .tag(Navigation.general)
                
                navigationEntry("Customization") {
                    Image(systemSymbol: .pencilAndOutline)
                }
                .tag(Navigation.customization)
                
                navigationEntry("Clipboard") {
                    Image(systemSymbol: .clipboard)
                }
                .tag(Navigation.clipboard)
                
                navigationEntry("Excluded Apps") {
                    Image(systemSymbol: .xmarkApp)
                }
                .tag(Navigation.excludedApps)
                
                navigationEntry("Syncing") {
                    Image(systemSymbol: .checkmarkIcloud)
                }
                .tag(Navigation.syncing)
                
                navigationEntry("About") {
                    Image(systemSymbol: .infoCircle)
                }
                .tag(Navigation.about)
                
#if DEBUG
                navigationEntry("Test (Debug)") {
                    Image(systemSymbol: .airplaneDeparture)
                }
                .tag(Navigation.test)
#endif
            }
            .navigationSplitViewColumnWidth(200)
        } detail: {
            Group {
                switch selectedNavigation {
                case .general:
                    GeneralSettingsPage()
                case .customization:
                    CustomizationSettingsPage()
                case .clipboard:
                    ClipboardSettingsPage()
                case .excludedApps:
                    ExcludedAppsSettingsPage()
                        .environmentObject(apps)
                case .syncing:
                    SyncingSettingsPage()
                case .about:
                    AboutSettingsPage()
                    
                case .test:
                    TestSettingsPage()
                }
            }
            .navigationSplitViewColumnWidth(min: 550, ideal: 550)
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        quit()
                    } label: {
                        Text("Quit")
                            .padding(4)
                    }
                    .controlSize(.extraLarge)
                }
            }
        }
        .navigationTitle(Bundle.main.appName)
        
        // An intermediate view to hide the ugly window toolbar transition
        .orSomeView(condition: !isWindowInitialized) {
            StaleView()
                .navigationTitle(Text(verbatim: ""))
        }
    }
}

#Preview {
    SettingsView(isWindowInitialized: .constant(true))
}
