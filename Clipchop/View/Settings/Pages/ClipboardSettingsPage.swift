//
//  ClipboardSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI

struct ClipboardSettingsPage: View {
    var body: some View {
        ListEmbeddedForm {
            KeyboardShortcutsSection()
                .controlSize(.large)
            
            ClipboardBehaviorsSection()
        }
    }
}

#Preview {
    previewPage {
        ClipboardSettingsPage()
    }
}
