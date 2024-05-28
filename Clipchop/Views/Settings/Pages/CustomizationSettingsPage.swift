//
//  CustomizationSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults
import SFSafeSymbols

struct CustomizationSettingsPage: View {
    var body: some View {
        listEmbeddedForm {
            AppearanceSection()
        }
    }
}

#Preview {
    previewPage {
        CustomizationSettingsPage()
    }
}
