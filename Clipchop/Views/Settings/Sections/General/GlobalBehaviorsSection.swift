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
    
    @Environment(\.hasTitle) var hasTitle
    
    var body: some View {
        Section {
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
        } header: {
            if hasTitle {
                Text("Global Behaviors")
            }
        }
    }
}

#Preview {
    previewSection {
        GlobalBehaviorsSection()
    }
}
