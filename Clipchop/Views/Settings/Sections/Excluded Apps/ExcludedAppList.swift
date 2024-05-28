//
//  ExcludedAppList.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/28.
//

import SwiftUI
import Defaults

struct ExcludedAppList: View {
    @EnvironmentObject private var apps: InstalledApps
    
    @Default(.applicationExcludeList) private var excluded
    
    @Binding var selection: Set<String>
    
    var removeSelected: () -> Void
    
    var body: some View {
        List(selection: $selection) {
            ForEach($excluded, id: \.self) { entry in
                Group {
                    if let app = (apps.installedApps + apps.systemApps).first(where: {
                        $0.bundleID == entry.wrappedValue
                    }) {
                        HStack {
                            Image(nsImage: app.icon)
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 20)
                            
                            Text(app.displayName)
                                .padding(.leading, 2)
                        }
                    } else {
                        Text(entry.wrappedValue)
                            .padding(.leading, 20 + 2)
                            .monospaced()
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
                    Button("Log to Console (Debug)") {
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
}
