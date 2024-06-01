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
                    List(selection: $selection) {
                        ForEach($excluded, id: \.self) { entry in
                            HStack {
                                Group {
                                    if let app = (apps.installedApps + apps.systemApps).first(where: {
                                        $0.bundleID == entry.wrappedValue
                                    }) {
                                        HStack {
                                            Image(nsImage: app.icon)
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .frame(width: 20)
                                            
                                            Text(app.displayName)
                                                .padding(.leading, 2)
                                        }
                                    } else {
                                        Text(entry.wrappedValue)
                                            .padding(.leading, 20 + 2)
                                            .monospaced()
                                    }
                                }
                                .padding(.vertical, 5)
                                .contextMenu {
                                    Button("Remove") {
                                        if selection.isEmpty {
                                            excluded.removeAll { $0 == entry.wrappedValue }
                                        } else {
                                            removeSelected()
                                        }
                                    }
                                    
#if DEBUG
                                    Button("Log to Console (Debug)") {
                                        selection.forEach {
                                            print($0)
                                        }
                                    }
#endif
                                }
                                .tag(entry.wrappedValue)
                                
                                Spacer()
                            }
                            // Requires a non-transparent background to expand the hit testing area
                            .background(.placeholder.opacity(0.0001))
                        }
                        .onMove { indexSet, destination in
                            excluded.move(fromOffsets: indexSet, toOffset: destination)
                        }
                        .onDelete { indexSet in
                            excluded.remove(atOffsets: indexSet)
                        }
                    }
                    .listStyle(.bordered)
                    .alternatingRowBackgrounds()
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
