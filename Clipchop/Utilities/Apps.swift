//
//  Apps.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Algorithms
import Defaults

class Apps: ObservableObject {
    struct App: Identifiable {
        var id: String { bundleID }
        var bundleID: String
        var icon: NSImage
        var displayName: String
        var installationFolder: String
    }
    
    private var query = NSMetadataQuery()
    
    @Published var installedApps = [App]()
    
    init() {
        self.startQuery()
    }
    
    deinit {
        query.stop()
    }
    
    private func startQuery() {
        query.predicate = NSPredicate(format: "kMDItemContentType == 'com.apple.application-bundle'")
        if let appFolder = FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask).first {
            query.searchScopes = [appFolder]
        }
        
        NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidFinishGathering,
            object: nil,
            queue: nil,
            using: queryDidFinishGathering
        )
        query.start()
    }
    
    private func queryDidFinishGathering(notification: Notification) {
        if let items  = query.results as? [NSMetadataItem] {
            self.installedApps = items.compactMap({ item in
                guard
                    let bundleId = item.value(forAttribute: NSMetadataItemCFBundleIdentifierKey) as? String,
                    let displayName = item.value(forAttribute: NSMetadataItemDisplayNameKey) as? String,
                    let path = item.value(forAttribute: NSMetadataItemPathKey) as? String,
                    let installationFolder = URL(string: path)?.deletingLastPathComponent().absoluteString.removingPercentEncoding
                else {
                    return nil
                }
                let icon = NSWorkspace.shared.icon(forFile: path)
                return App(
                    bundleID: bundleId,
                    icon: icon,
                    displayName: displayName,
                    installationFolder: installationFolder
                )
            })
        }
    }
}
