//
//  ExcludedAppsSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI

struct ExcludedAppsSettingsPage: View {
    @EnvironmentObject var apps: Apps
    
    var body: some View {
        Form {
            ExcludedAppListSection()
                .environmentObject(apps)
        }
    }
}

#Preview {
    ExcludedAppsSettingsPage()
        .formStyle(.grouped)
        .environmentObject(Apps())
}
