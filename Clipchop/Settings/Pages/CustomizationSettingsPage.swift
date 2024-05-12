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
    @Default(.appIcon) var appIcon
    @Default(.sound) var sound
    
    @Default(.accentColor) var accentColor
    
    @Default(.timesClipped) var timesClipped

    var body: some View {
        Form {
            
        }
    }
}

#Preview {
    CustomizationSettingsPage()
}
