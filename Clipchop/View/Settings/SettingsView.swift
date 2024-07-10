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
        
        var hasUniversalToolbar: Bool {
            switch self {
            case .categorization: false
            default: true
            }
        }
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
            .frame(width: 180) // `navigationSplitColumnWidth` doesn't work
            .toolbar(removing: .sidebarToggle)
            .navigationSplitViewColumnWidth(min: 180, ideal: 180, max: 180)
        } detail: {
            contentForNavigation(navigation)
                .navigationSplitViewColumnWidth(min: 500, ideal: 500, max: 500)
            .toolbar {
                if navigation.hasUniversalToolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
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
            .navigationSplitViewCollapsingDisabled()
            .navigationTitle(Bundle.main.appName)
            .navigationSplitViewStyle(.prominentDetail)
            .background(WindowAccessor())
        }
    }
    @ViewBuilder
    private func contentForNavigation(_ navigation: Navigation) -> some View {
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
            
        #if DEBUG
        case .test:
            TestSettingsPage()
        #endif
            
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
