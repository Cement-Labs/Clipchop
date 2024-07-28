//
//  LuminareExcludedAppsSettings.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/28.
//

import SwiftUI
import Luminare
import Defaults
import SFSafeSymbols

struct LuminareExcludedAppsSettings: View {
    @EnvironmentObject private var apps: InstalledApps
    @Default(.excludeAppsEnabled) private var excludeAppsEnabled
    @Default(.excludedApplications) private var excluded
    @State private var selection: Set<String> = .init()
    
    var body: some View {
        LuminareSection {
            HStack {
                withCaption {
                    Text("App Excluding")
                } caption: {
                    Text("""
Limit \(Bundle.main.appName)'s functions in the specified apps.
""")
                }
                Spacer()
                
                Toggle("", isOn: $excludeAppsEnabled)
                    .labelsHidden()
                    .controlSize(.small)
                    .toggleStyle(.switch)
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 42)
        }
        
        CustomLuminareList(
            items: $excluded,
            selection: $selection,
            addActionView: {
                InstalledAppsMenu()
                    .environmentObject(apps)
            },
            removeAction: {
                excluded.removeAll(where: { selection.contains($0) })
            },
            content: { entry in
                HStack {
                    Group {
                        if let app = (apps.installedApps + apps.systemApps).first(where: {
                            $0.bundleID == entry
                        }) {
                            HStack {
                                Image(nsImage: app.icon)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: 20)
                                
                                Text(app.displayName)
                                    .padding(.leading, 2)
                            }
                            .padding(.leading, 8)

                        } else {
                            Text(entry)
                                .padding(.leading, 22)
                                .monospaced()
                        }
                    }
                    .padding(.vertical, 5)
                    .tag(entry)
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.trailing, 2)
                .frame(minHeight: 34)
            },
            emptyView: {
                HStack {
                    Spacer()
                    VStack {
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
            },
            id: \.self,
            addText: "Add",
            removeText: "Remove"
        )
    }
    private func removeSelected() {
        excluded.removeAll { selection.contains($0) }
        selection.removeAll()
    }
}
