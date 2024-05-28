//
//  ExcludedAppsSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI

struct ExcludedAppsSettingsPage: View {
    @EnvironmentObject private var apps: InstalledApps
    
    var body: some View {
        listEmbeddedForm {
            ExcludedAppListSection()
                .environmentObject(apps)
        }
    }
}

#Preview {
    previewPage {
        ExcludedAppsSettingsPage()
            .environmentObject(InstalledApps())
    }
}
