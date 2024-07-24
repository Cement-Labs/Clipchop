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
<<<<<<<< HEAD:Clipchop/Views/Settings/Pages/GeneralSettingsPage.swift
========
        .preferredColorScheme(preferredColorScheme.colorScheme)
>>>>>>>> origin/rewrite/main:Clipchop/View/Settings/Pages/GeneralSettingsPage.swift
    }
}


#Preview {
    previewPage {
        GeneralSettingsPage()
    }
}
