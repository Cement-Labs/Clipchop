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
    @State private var launchAtLogin: Bool = LaunchAtLogin.isEnabled
    
    // Global Behaviors
    @State private var showPopoverMore = false
    @State private var displayMoreChanged = false
    
    @Default(.preferredColorScheme) private var preferredColorScheme
    @Default(.menuBarItemEnabled) private var menuBarItemEnabled
    @Default(.autoCloseTimeout) private var autoCloseTimeout
    @Default(.cursorPosition) private var cursorPosition
    @Default(.displayMore) private var displayMore
    
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
            
            LuminareToggle("Starts with macOS" ,isOn: $launchAtLogin)
            
            LuminareToggle(
                "Shows menu bar item",
                info: .init("You can always open \(Bundle.main.appName) again to access this page.", .orange),
                isOn: $menuBarItemEnabled
            )
        }
        
        LuminareSection("Panel Behaviors") {
            
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
        .preferredColorScheme(preferredColorScheme.colorScheme)
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
