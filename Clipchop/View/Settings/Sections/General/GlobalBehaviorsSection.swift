//
//  GlobalBehaviorsSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import Defaults
import LaunchAtLogin

struct GlobalBehaviorsSection: View {
    
    @Default(.menuBarItemEnabled) private var menuBarItemEnabled
    
    @Environment(\.hasTitle) private var hasTitle
    
    var body: some View {
        Section {
            LaunchAtLogin.Toggle {
                Text("Starts with macOS")
            }
            
            withCaption("""
You can always open \(Bundle.main.appName) again to access this page.
""") {
                    
                    Toggle("Shows menu bar item", isOn: $menuBarItemEnabled)
            }
        } header: {
            if hasTitle {
                Text("Global Behaviors")
            }
        }
    }
}
