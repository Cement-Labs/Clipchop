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
        Section("Global Behaviors") {
            HStack {
                Text("Starts with macOS")
                
                Spacer()
                
                LaunchAtLogin.Toggle {
                    EmptyView()
                }
            }
            
            withCaption("""
You can always open \(Bundle.main.appName) again to access this page.
""") {
                HStack {
                    Text("Shows menu bar item")
                    
                    Spacer()
                    
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
    .formStyle(.grouped)
}
