//
//  CustomizationSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI

struct CustomizationSettingsPage: View {
    var body: some View {
        ListEmbeddedForm {
            AppearanceSection()
        }
    }
}

#Preview {
    previewPage {
        CustomizationSettingsPage()
    }
}
