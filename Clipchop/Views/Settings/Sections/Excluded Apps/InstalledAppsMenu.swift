//
//  InstalledAppsMenu.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults

struct InstalledAppsMenu: View {
    @EnvironmentObject private var apps: InstalledApps
    
    @Default(.excludedApplications) private var excluded
    
    var entry: String?
    
    init(entry: String? = nil) {
        self.entry = entry
    }
    
    var body: some View {
        let availableApps = (apps.installedApps + apps.systemApps)
            .filter { !excluded.contains($0.bundleID) }
            .grouped { $0.installationFolder }
        let installationFolders = availableApps.keys
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        
        ForEach(installationFolders, id: \.self) { folder in
            Section(folder) {
                let containedApps = availableApps[folder]!.sorted {
                    $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
                }
                
                ForEach(containedApps) { app in
                    Button {
                        if 
                            let entry,
                            let destination = excluded.firstIndex(of: entry)
                        {
                            excluded.insert(app.bundleID, at: excluded.index(after: destination))
                        } else {
                            excluded.append(app.bundleID)
                        }
                    } label: {
                        Image(nsImage: app.icon.resized(to: .init(width: 16, height: 16)))
                        Text(app.displayName)
                    }
                }
            }
        }
    }
}
