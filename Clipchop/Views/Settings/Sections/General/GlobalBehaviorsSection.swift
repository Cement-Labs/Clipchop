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
    @Default(.autoCloseTimeout) private var autoCloseTimeout
    @Default(.cursorPosition) private var cursorPosition
    @Default(.displayMore) private var displayMore
    
    @Environment(\.hasTitle) private var hasTitle
    
    @State private var showPopoverMore = false
    @State private var displayMoreChanged = false
    
    private var controller: ClipHistoryPanelController = ClipHistoryPanelController()
    
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
        Section {
            withCaption("This option will determine where your panel appears") {
                HStack{
                    Text("Panel Position")
                    if Defaults[.cursorPosition] == .adjustedPosition {
                        Button(action: {
                            self.showPopoverMore.toggle()
                        }) {
                            Image(systemSymbol: .infoCircle)
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $showPopoverMore, arrowEdge: .top) {
                            VStack {
                                Text("Some applications are not available and are displayed at the cursor.")
                                    .font(.body)
                            }
                            .frame(width: 200, height: 100)
                            .padding()
                        }
                    }
                    Spacer()
                    Picker("", selection: $cursorPosition) {
                        Text("At the mouse").tag(CursorPosition.mouseLocation)
                        Text("At the cursor").tag(CursorPosition.adjustedPosition)
                    }
                }
            }
            withCaption("This action will enlarge the panel size to display more content.") {
                Toggle("Display More", isOn: $displayMore)
                    .onChange(of: displayMore) { newValue, _ in
                        controller.logoutpanel()
                    }
            }
            VStack {
                HStack {
                    Text("Auto Close Timeout")
                    Spacer()
                    Text("\(Int(autoCloseTimeout))s")
                        .monospaced()
                }
                Slider(value: $autoCloseTimeout, in: 5...60) {
                    
                } minimumValueLabel: {
                    Text("5")
                } maximumValueLabel: {
                    Text("60")
                }
                .monospaced()
            }
        } header: {
            if hasTitle {
                Text("Panel Behaviors")
            }
        }
    }
}
