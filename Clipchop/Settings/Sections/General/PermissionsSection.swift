//
//  PermissionsSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import Defaults

struct PermissionsSection: View {
    @State var isAccessibilityAccessGranted = false
    @State var isFullDiskAccessGranted = false
    
    let permissionsAutoCheck = Timer.publish(
        every: 1, tolerance: 0.5,
        on: .main, in: .common
    ).autoconnect()
    
    @ViewBuilder
    func grantAccessButton(isGranted: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Group {
                Text("Grant")
                Image(systemSymbol: .arrowRightCircleFill)
            }
            .or(condition: isGranted) {
                Group {
                    Text("Granted")
                    Image(systemSymbol: .checkmarkSealFill)
                }
            }
            .frame(height: 16)
        }
        .controlSize(.large)
        .buttonStyle(.borderless)
        .buttonBorderShape(.capsule)
        .disabled(isGranted)
        .tint(isGranted ? .secondary : .red)
    }
    
    var body: some View {
        Section("Permissions") {
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
Full Disk Access is neede to generate file previews.
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
        }
    }
}

#Preview {
    previewSection {
        PermissionsSection()
    }
}
