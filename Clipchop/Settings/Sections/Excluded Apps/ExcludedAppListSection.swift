//
//  ExcludedAppListSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults
import SFSafeSymbols

struct ExcludedAppListSection: View {
    @EnvironmentObject var apps: InstalledApps
    
    @Default(.excludeAppsEnabled) var excludeAppsEnabled
    @Default(.applicationExcludeList) var excluded
    
    @State private var selection = Set<String>()
    
    func removeSelected() {
        for item in selection {
            self.excluded.removeAll { $0 == item }
        }
        selection.removeAll()
    }
    
    @ViewBuilder
    func excludedList() -> some View {
        List(selection: $selection) {
            ForEach($excluded, id: \.self) { entry in
                Group {
                    if let app = (apps.installedApps + apps.systemApps).first(where: {
                        $0.bundleID == entry.wrappedValue
                    }) {
                        HStack {
                            Image(nsImage: app.icon.resized(to: .init(width: 20, height: 20)))
                            Text(app.displayName)
                                .padding(.leading, 2)
                        }
                    } else {
                        Text(entry.wrappedValue)
                    }
                }
                .padding(.vertical, 5)
                .contextMenu {
                    Button("Remove") {
                        if selection.isEmpty {
                            excluded.removeAll { $0 == entry.wrappedValue }
                        } else {
                            removeSelected()
                        }
                    }
                    
#if DEBUG
                    Button("Log to Console") {
                        selection.forEach {
                            print($0)
                        }
                    }
#endif
                }
                .tag(entry.wrappedValue)
            }
            .onMove { indices, destination in
                excluded.move(fromOffsets: indices, toOffset: destination)
            }
            .onDelete { offsets in
                excluded.remove(atOffsets: offsets)
            }
        }
        .listStyle(.bordered)
        .alternatingRowBackgrounds()
    }
    
    @ViewBuilder
    func sectionFooter() -> some View {
        Rectangle()
            .frame(height: 20)
            .foregroundStyle(.quinary)
            .overlay {
                HStack(spacing: 2) {
                    Spacer()
                    
                    // Remove
                    Button {
                        removeSelected()
                    } label: {
                        sectionFooterButton(systemSymbol: .minus)
                    }
                    .buttonStyle(.borderless)
                    .disabled(selection.isEmpty)
                    
                    // Add
                    Menu {
                        InstalledAppsMenu()
                            .environmentObject(apps)
                    } label: {
                        sectionFooterButton(systemSymbol: .plus)
                    }
                    .aspectRatio(contentMode: .fit)
                }
            }
            .disabled(!excludeAppsEnabled)
    }
    
    @ViewBuilder
    func sectionFooterButton(systemSymbol: SFSymbol) -> some View {
        Rectangle()
            .foregroundStyle(.placeholder.opacity(0))
            .overlay {
                Image(systemSymbol: systemSymbol)
                    .font(.footnote)
                    .fontWeight(.semibold)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(-5)
    }
    
    var body: some View {
        Section {
            withCaption("Limit \(Bundle.main.appName)'s functions in the specified apps.") {
                Toggle("Allow app excluding", isOn: $excludeAppsEnabled)
                .toggleStyle(.switch)
            }
        }
        
        if excludeAppsEnabled {
            Section {
                VStack(spacing: 0) {
                    if excluded.isEmpty {
                        // No app excluded.
                        HStack {
                            Spacer()
                            
                            VStack {
                                Image(systemSymbol: .appDashed)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 32)
                                    .foregroundStyle(.placeholder)
                                
                                Text("No Application Excluded")
                                    .font(.title3)
                                
                                description {
                                    Text("Exclude apps to prevent \(Bundle.main.appName) copying their contents.")
                                }
                            }
                            
                            Spacer()
                        }
                        .foregroundStyle(.secondary)
                        .padding()
                    } else {
                        excludedList()
                    }
                    
                    Divider()
                    
                    sectionFooter()
                        .padding(.bottom, 1)
                }
                .ignoresSafeArea()
                .padding(-10)
            }
        }
    }
}

#Preview {
    previewSection {
        ExcludedAppListSection()
            .environmentObject(InstalledApps())
    }
}
