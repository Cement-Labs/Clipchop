//
//  SettingsView.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import SFSafeSymbols
import Defaults
import SwiftUIIntrospect

struct SettingsView: View {
    enum Navigation {
        case general
        case customization
        case clipboard
        case categories
        case excludedApps
        case syncing
        case about
        
#if DEBUG
        case test
#endif
    }
    
    @State var selectedNavigation: Navigation = .general
    @State var apps = InstalledApps()
    
    @Binding var isWindowInitialized: Bool
    
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
                
                navigationEntry("Categories") {
                    Image(systemSymbol: .tray2)
                }
                .tag(Navigation.categories)
                
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
            .frame(minWidth: 200)
            .toolbar(removing: .sidebarToggle)
        } detail: {
            Group {
                switch selectedNavigation {
                    
                case .general:
                    GeneralSettingsPage()
                    
                case .customization:
                    CustomizationSettingsPage()
                    
                case .clipboard:
                    ClipboardSettingsPage()
                    
                case .categories:
                    CategoriesPage()
                
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
            
            // Completely prevents the sidebar from collapsing
            .introspect(.navigationSplitView, on: .macOS(.v14), scope: .ancestor) { splitView in
                (splitView.delegate as? NSSplitViewController)?.splitViewItems.forEach { $0.canCollapse = false }
            }
        }
        .navigationTitle(Bundle.main.appName)
        .navigationSplitViewStyle(.prominentDetail)
        
        // An intermediate view to hide the ugly window toolbar transition
        .orSomeView(condition: !isWindowInitialized) {
            ZStack {
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                    .ignoresSafeArea()
                
                StaleView()
                    .blendMode(.overlay)
            }
            .navigationTitle(Text(verbatim: ""))
        }
    }
}

#Preview {
    SettingsView(isWindowInitialized: .constant(true))
}
