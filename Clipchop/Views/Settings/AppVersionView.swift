//
//  AppVersionView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/13.
//

import SwiftUI
import SFSafeSymbols

var semanticVersion: String {
    .init(
        format: String(localized: "App Version: Semantic", defaultValue: "Version %@"),
        rawVersion
    )
}

var rawVersion: String {
    .init(
        format: String(localized: "App Version: Raw", defaultValue: "%1$@ Build %2$@"),
        Bundle.main.appVersion, Bundle.main.appBuild
    )
}

struct AppVersionView: View {
    var body: some View {
        Button {
            let pasteboard = NSPasteboard.general
            
            pasteboard.clearContents()
            pasteboard.setString(rawVersion, forType: .string)
        } label: {
            Image(systemSymbol: .infoCircle)
            Text(semanticVersion)
        }
        .monospaced()
        .buttonStyle(.plain)
    }
}
