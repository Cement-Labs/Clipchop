//
//  GeneralSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI

struct GeneralSettingsPage: View {
    var body: some View {
        listEmbeddedForm {
            PermissionsSection()
            
            GlobalBehaviorsSection()
            
            Section {
                PreferredColorSchemePicker()
            }
        }
    }
}

#Preview {
    previewPage {
        GeneralSettingsPage()
    }
}
