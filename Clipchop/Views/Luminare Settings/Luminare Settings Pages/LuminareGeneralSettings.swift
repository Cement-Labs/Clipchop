//
//  LuminareGeneralSettings.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/26.
//

import SwiftUI
import Luminare
import Defaults

import LaunchAtLogin
import FullDiskAccess

struct LuminareGeneralSettings: View {
    
    // Permissions
    @State private var isAccessibilityAccessGranted = false
    @State private var isFullDiskAccessGranted = false
    
    // Global Behaviors
    @State private var showPopoverMore = false
    @State private var displayMoreChanged = false
    
    @Default(.menuBarItemEnabled) private var menuBarItemEnabled
    @Default(.sendNotification) private var sendNotification
    @Default(.autoCloseTimeout) private var autoCloseTimeout
    @Default(.cursorPosition) private var cursorPosition
    @Default(.displayMore) private var displayMore
    @Default(.autoClose) private var autoClose
    @Default(.hideTag) private var hideTag
    
    private var controller: ClipHistoryPanelController = ClipHistoryPanelController()
    
    private let permissionsAutoCheck = Timer.publish(
        every: 1, tolerance: 0.5,
        on: .main, in: .common
    ).autoconnect()
    
    var body: some View {
        LuminareSection("Permissions") {
            HStack {
                withCaption {
                    Text("Accessibility Access")
                } caption: {
                    Text("""
Accessibility Access is needed to take over your clipboard.
""")
                }
                .padding(.horizontal, 8)
                .padding(.trailing, 2)
                .frame(minHeight: 42)
                
                Spacer()
                
                grantAccessButton(isGranted: isAccessibilityAccessGranted) {
                    isAccessibilityAccessGranted = PermissionsManager.Accessibility.requestAccess()
                }
                
                .onAppear {
                    isAccessibilityAccessGranted = PermissionsManager.Accessibility.getStatus()
                }
#if !DEBUG
                .onReceive(permissionsAutoCheck) { _ in
                    isAccessibilityAccessGranted = PermissionsManager.Accessibility.getStatus()
                }
#endif

            }
            HStack {
                withCaption {
                    Text("Full Disk Access")
                } caption: {
                    Text("""
Full Disk Access is needed to generate file previews.
""")
                }
                .padding(.horizontal, 8)
                .padding(.trailing, 2)
                .frame(minHeight: 42)
                
                Spacer()
                
                grantAccessButton(isGranted: isFullDiskAccessGranted) {
                    isFullDiskAccessGranted = PermissionsManager.FullDisk.requestAccess()
                }
                .onAppear {
                    isFullDiskAccessGranted = PermissionsManager.FullDisk.getStatus()
                }
#if !DEBUG
                .onReceive(permissionsAutoCheck) { _ in
                    isFullDiskAccessGranted = PermissionsManager.FullDisk.getStatus()
                }
#endif
            }
#if DEBUG
            Button("Refresh States (Debug)") {
                isAccessibilityAccessGranted = PermissionsManager.Accessibility.getStatus()
                isFullDiskAccessGranted = PermissionsManager.FullDisk.getStatus()
            }
#endif
        }
        LuminareSection("Global Behaviors") {
            
            HStack {
                Text("Starts with macOS")
                Spacer()
                LaunchAtLogin.Toggle("")
                .toggleStyle(.switch)
                .controlSize(.small)
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 34)
            
            LuminareToggle(
                "Shows menu bar item",
                info: .init("You can always open \(Bundle.main.appName) again to access this page.", .orange),
                isOn: $menuBarItemEnabled
            )
            
            LuminareToggle (
                "Send Notification",
                isOn: $sendNotification
            )
        }
        
        LuminareSection("Panel Behaviors") {
            
            LuminareToggle("Hide tag" ,isOn: $hideTag)
            
            HStack {
                withCaption {
                    Text("Display More")
                } caption: {
                    Text("""
    This action will enlarge the panel size to display more content.
    """)
                }
                
                Spacer()
                Toggle("", isOn: $displayMore)
                    .onChange(of: displayMore) { newValue, _ in
                        controller.logoutpanel()
                    }
                    .labelsHidden()
                    .controlSize(.small)
                    .toggleStyle(.switch)
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 42)
            
            HStack {
                withCaption {
                    HStack(spacing: 0) {
                        Text("Panel Position")
                        if Defaults[.cursorPosition] == .adjustedPosition {
                            LuminareInfoView("Some applications are not available and are displayed at the cursor.", .orange)
                        }
                    }
                    .fixedSize()
                } caption: {
                    Text("""
        This option will determine where your panel appears
        """)
                }
                
                Spacer()
                
                CustomLuminarePicker(selection: $cursorPosition, items: CursorPosition.allCases, displayText: { $0.displayText })
                
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 42)
            
        }
        
        LuminareSection() {
            VStack {
                LuminareToggle("Auto Close" ,isOn: $autoClose)
            }
            if Defaults[.autoClose] {
                VStack {
                    LuminareValueAdjuster(
                        "Auto Close Timeout",
                        value: $autoCloseTimeout,
                        sliderRange: 5...60,
                        suffix: "s",
                        lowerClamp: true
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private func grantAccessButton(isGranted: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Group {
                Text("Grant")
                    .fixedSize()
                
                Image(systemSymbol: .arrowRightCircleFill)
            }
            .or(isGranted) {
                Group {
                    Text("Granted")
                        .fixedSize()
                    
                    Image(systemSymbol: .checkmarkSealFill)
                }
            }
            .frame(height: 16)
        }
        .animation(.default, value: isGranted)
        .controlSize(.large)
        .buttonStyle(.borderless)
        .buttonBorderShape(.capsule)
        .disabled(isGranted)
        .tint(isGranted ? .secondary : .red)
        .padding(.horizontal, 8)
        .padding(.trailing, 2)
        .frame(minHeight: 34)
    }
}
