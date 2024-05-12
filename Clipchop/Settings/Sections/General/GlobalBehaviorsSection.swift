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
    @Default(.menuBarItemEnabled) var menuBarItemEnabled
    
    var body: some View {
        section("Global Behaviors") {
            HStack {
                Text("Starts with macOS")
                
                LaunchAtLogin.Toggle {
                    EmptyView()
                }
            }
            
            withCaption("""
You can open \(Bundle.main.appName) again to access this page.
""") {
                HStack {
                    Text("Show menu bar item")
                    
                    Toggle(isOn: $menuBarItemEnabled) {
                        EmptyView()
                    }
                }
            }
        }
    }
}

#Preview {
    Form {
        GlobalBehaviorsSection()
    }
}
