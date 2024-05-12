//
//  AppearanceSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults

struct AppearanceSection: View {
    @Default(.timesClipped) var timesClipped
    @Default(.appIcon) var appIcon
    
    var body: some View {
        section("Appearance") {
            withCaption("""
Clip more to unlock more! You've already clipped \(timesClipped) times.
""") {
                Picker("App icon", selection: $appIcon) {
                    ForEach(Icons.unlockedIcons, id: \.self) { icon in
                        HStack {
                            Image(nsImage: icon.image)
                            Text(icon.name ?? "")
                        }
                        .tag(icon.assetName)
                    }
                }
                .onChange(of: appIcon) { oldIcon, newIcon in
                    Icons.setAppIcon(to: newIcon)
                }
            }
        }
    }
}

#Preview {
    AppearanceSection()
}
