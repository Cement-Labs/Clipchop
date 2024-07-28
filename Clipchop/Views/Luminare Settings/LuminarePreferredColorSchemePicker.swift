//
//  LuminarePreferredColorSchemePicker.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/28.
//

import SwiftUI
import Defaults

struct LuminarePreferredColorSchemePicker: View {
    @Default(.preferredColorScheme) private var preferredColorScheme
    
    var body: some View {
        CustomLuminarePicker(
            selection: $preferredColorScheme,
            items: PreferredColorScheme.allCases
        ) { scheme in
            scheme.displayName
        }
        .frame(width: 80, height: 24, alignment: .trailing)
        .controlSize(.regular)
        .onChange(of: preferredColorScheme) { newValue, _ in
            applyColorScheme()
        }
        .onAppear {
            applyColorScheme()
        }
    }
    
    private func applyColorScheme() {
        switch preferredColorScheme {
        case .system:
            NSApplication.shared.appearance = nil
        case .light:
            NSApplication.shared.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
        }
    }
}

#Preview {
    LuminarePreferredColorSchemePicker()
}
