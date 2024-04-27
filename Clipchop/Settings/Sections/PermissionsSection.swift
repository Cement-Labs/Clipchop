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
    
    let permissionsAutoCheck = Timer.publish(
        every: 1, tolerance: 0.5,
        on: .main, in: .common
    ).autoconnect()
    
    var body: some View {
        section("Permissions") {
            withCaption("""
\(Bundle.main.appName) requires Accessibility Permissions to take over your clipboard. No data will be collected remotely.
""") {
                HStack {
                    Text("Accessibility Access")
                    
                    Button {
                        withAnimation {
                            isAccessibilityAccessGranted = PermissionsManager.Accessibility.requestAccess()
                        }
                    } label: {
                        Group {
                            Text("Grant")
                            Image(systemSymbol: .arrowRight)
                        }
                        .or(condition: isAccessibilityAccessGranted) {
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
                    .disabled(isAccessibilityAccessGranted)
                    
                    .tint(isAccessibilityAccessGranted ? .green : .red)
                    .task {
                        isAccessibilityAccessGranted = PermissionsManager.Accessibility.getStatus()
                    }
                    .onReceive(permissionsAutoCheck) { _ in
                        isAccessibilityAccessGranted = PermissionsManager.Accessibility.getStatus()
                    }
                }
            }
        }
    }
}

#Preview {
    Form {
        PermissionsSection()
    }
}
