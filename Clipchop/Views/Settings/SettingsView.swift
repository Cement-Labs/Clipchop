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
        case categorization
        case appExcluding
        case syncing
        case about
        
#if DEBUG
        case test
#endif
    }
    
    @State private var navigation: Navigation = .general
    @State private var apps = InstalledApps()
    
    var body: some View {
        NavigationSplitView {
            List(selection: $navigation) {
                NavigationEntry("General") {
                    Image(systemSymbol: .gearshape)
                }
                .tag(Navigation.general)
                
                NavigationEntry("Customization") {
                    Image(systemSymbol: .pencilAndOutline)
                }
                .tag(Navigation.customization)
                
                NavigationEntry("Clipboard") {
                    Image(systemSymbol: .clipboard)
                }
                .tag(Navigation.clipboard)
                
                NavigationEntry("Categorization") {
                    Image(systemSymbol: .tray2)
                }
                .tag(Navigation.categorization)
                
                NavigationEntry("App Excluding") {
                    Image(systemSymbol: .xmarkSeal)
                }
                .tag(Navigation.appExcluding)
                
                NavigationEntry("Syncing") {
                    Image(systemSymbol: .checkmarkIcloud)
                }
                .tag(Navigation.syncing)
                
                NavigationEntry("About") {
                    Image(systemSymbol: .infoCircle)
                }
                .tag(Navigation.about)
                
#if DEBUG
                NavigationEntry("Test (Debug)") {
                    Image(systemSymbol: .airplaneDeparture)
                }
                .tag(Navigation.test)
#endif
            }
            .frame(width: 200) // `navigationSplitColumnWidth` doesn't work
            .toolbar(removing: .sidebarToggle)
        } detail: {
            Group {
                switch navigation {
                    
                case .general:
                    GeneralSettingsPage()
                    
                case .customization:
                    CustomizationSettingsPage()
                    
                case .clipboard:
                    ClipboardSettingsPage()
                    
                case .categorization:
                    CategorizationPage()
                
                case .appExcluding:
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
            .navigationSplitViewCollapsingDisabled()
            .navigationTitle(Bundle.main.appName)
            .navigationSplitViewStyle(.prominentDetail)
            .background(WindowAccessor())
        }
    }
}

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.toolbarStyle = .unified
                window.titlebarAppearsTransparent = false
                window.titlebarSeparatorStyle = .automatic
                window.makeKeyAndOrderFront(nil)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

#Preview {
    SettingsView()
}
