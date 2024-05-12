//
//  InstalledAppsMenu.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults

struct InstalledAppsMenu: View {
    @EnvironmentObject var apps: Apps
    
    @Default(.applicationExcludeList) var excluded
    
    var body: some View {
        let availableApps = apps.installedApps
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
                        excluded.append(app.bundleID)
                        print("Excluded: \(app.bundleID)")
                    } label: {
                        Image(nsImage: app.icon.resized(to: .init(width: 16, height: 16)))
                        Text(app.displayName)
                    }
                }
            }
        }
    }
}
