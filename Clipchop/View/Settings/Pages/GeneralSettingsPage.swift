//
//  GeneralSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import Defaults

struct GeneralSettingsPage: View {
    @Default(.preferredColorScheme) private var preferredColorScheme
    var body: some View {
        ListEmbeddedForm {
            PermissionsSection()
            
            GlobalBehaviorsSection()
        }
        .preferredColorScheme(preferredColorScheme.colorScheme)
    }
}


#Preview {
    previewPage {
        GeneralSettingsPage()
    }
}
