//
//  PreferredColorSchemePicker.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/19.
//


import SwiftUI
import Defaults

struct PreferredColorSchemePicker: View {
    @Default(.preferredColorScheme) private var preferredColorScheme
    
    var body: some View {
        Picker("Preferred color scheme", selection: $preferredColorScheme) {
            Text("System").tag(PreferredColorScheme.system)
            Text("Light").tag(PreferredColorScheme.light)
            Text("Dark").tag(PreferredColorScheme.dark)
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: preferredColorScheme) { _, _ in
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

