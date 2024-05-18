//
//  GeneralSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI

struct GeneralSettingsPage: View {
    var body: some View {
        Form {
            PermissionsSection()
            
            GlobalBehaviorsSection()
        }
    }
}

#Preview {
    previewPage {
        GeneralSettingsPage()
    }
}
