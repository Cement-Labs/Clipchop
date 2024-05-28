//
//  ExcludedAppListSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults
import SFSafeSymbols

struct ExcludedAppListSection: View {
    @EnvironmentObject private var apps: InstalledApps
    
    @Default(.excludeAppsEnabled) private var excludeAppsEnabled
    @Default(.applicationExcludeList) private var excluded
    
    @State private var selection: Set<String> = .init()
    
    var body: some View {
        Section {
            withCaption("Limit \(Bundle.main.appName)'s functions in the specified apps.") {
                Toggle("Allow app excluding", isOn: $excludeAppsEnabled)
            }
        }
        
        Section {
            FormSectionList {
                if excluded.isEmpty {
                    // No app excluded
                    HStack {
                        Spacer()
                        
                        VStack {
                            Image(systemSymbol: .appDashed)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 32)
                                .foregroundStyle(.placeholder)
                            
                            Text("No Application Excluded")
                                .font(.title3)
                            
                            description {
                                Text("Exclude apps to prevent \(Bundle.main.appName) copying their contents.")
                            }
                        }
                        
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    .padding()
                } else {
                    ExcludedAppList(selection: $selection, removeSelected: removeSelected)
                        .environmentObject(apps)
                }
            } footer: {
                Spacer()
                
                // Remove
                Button {
                    removeSelected()
                } label: {
                    FormSectionFooterLabel(symbol: .minus)
                }
                .buttonStyle(.borderless)
                .disabled(selection.isEmpty)
                
                // Add
                Menu {
                    InstalledAppsMenu()
                        .environmentObject(apps)
                } label: {
                    FormSectionFooterLabel(symbol: .plus)
                }
                .aspectRatio(contentMode: .fit)
            }
        }
    }
    
    private func removeSelected() {
        for item in selection {
            excluded.removeAll { $0 == item }
        }
        selection.removeAll()
    }
}

#Preview {
    previewSection {
        ExcludedAppListSection()
            .environmentObject(InstalledApps())
    }
}
