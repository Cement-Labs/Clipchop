//
//  PermissionsSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import Defaults

struct PermissionsSection: View {
    @State var isAccessibilityAccessGranted: Bool = false
    @State var isFullDiskAccessGranted: Bool = false
    
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
                Image(systemSymbol: .arrowRight)
            }
            .or(condition: isGranted) {
                Group {
                    Text("Granted")
                    Image(systemSymbol: .checkmarkSeal)
                }
            }
            .frame(height: 12)
        }
        .controlSize(.small)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .disabled(isGranted)
        .tint(isGranted ? .green : .red)
    }
    
    var body: some View {
        Section("Permissions") {
            withCaption {
                HStack {
                    Text("Accessibility Access")
                    
                    Spacer()
                    
                    grantAccessButton(isGranted: isAccessibilityAccessGranted) {
                        withAnimation {
                            isAccessibilityAccessGranted = PermissionsManager.Accessibility.requestAccess()
                        }
                    }
                    .task {
                        isAccessibilityAccessGranted = PermissionsManager.Accessibility.getStatus()
                    }
                    .onReceive(permissionsAutoCheck) { _ in
                        isAccessibilityAccessGranted = PermissionsManager.Accessibility.getStatus()
                    }
                }
            } label: {
                Text("""
Accessibility Access is needed to take over your clipboard.
""")
            }
            
            withCaption {
                HStack {
                    Text("Full Disk Access")
                    
                    Spacer()
                    
                    grantAccessButton(isGranted: isFullDiskAccessGranted) {
                        withAnimation {
                            isFullDiskAccessGranted = PermissionsManager.FullDisk.requestAccess()
                        }
                    }
                    .task {
                        isFullDiskAccessGranted = PermissionsManager.FullDisk.getStatus()
                    }
                    .onReceive(permissionsAutoCheck) { _ in
                        isFullDiskAccessGranted = PermissionsManager.FullDisk.getStatus()
                    }
                }
            } label: {
                Text("""
Full Disk Access is neede to generate file previews.
""")
            }
        }
    }
}

#Preview {
    Form {
        PermissionsSection()
    }
}