//
//  PermissionsSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import Defaults

import LaunchAtLogin
import FullDiskAccess

struct PermissionsSection: View {
    
    @State private var isAccessibilityAccessGranted = false
    @State private var isFullDiskAccessGranted = false
    
    @Environment(\.hasTitle) private var hasTitle
    
    private let permissionsAutoCheck = Timer.publish(
        every: 1, tolerance: 0.5,
        on: .main, in: .common
    ).autoconnect()
    
    var body: some View {
        Section {
            HStack {
                withCaption {
                    Text("Accessibility Access")
                } caption: {
                    Text("""
Accessibility Access is needed to take over your clipboard.
""")
                }
                
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
        } header: {
            if hasTitle {
                Text("Permissions")
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
    }
}
