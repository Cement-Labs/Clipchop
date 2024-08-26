//
//  InstalledApp.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Algorithms
import Defaults


struct InstalledApp: Identifiable {
    var id: String { bundleID }
    var bundleID: String
    var icon: NSImage
    var displayName: String
    var installationFolder: String
}

class InstalledApps: ObservableObject {
    private var systemQuery = NSMetadataQuery()
    private var localQuery = NSMetadataQuery()
    
    @Published var systemApps = [InstalledApp]()
    @Published var installedApps = [InstalledApp]()
    
    init() {
        self.ensureFinderApp()
        
        self.startQuery(&systemQuery, in: .systemDomainMask) {
            self.queryDidFinishGathering(self.systemQuery, to: &self.systemApps, notification: $0)
            self.ensureFinderApp()
        }
        
        self.startQuery(&localQuery, in: .localDomainMask) {
            self.queryDidFinishGathering(self.localQuery, to: &self.installedApps, notification: $0)
        }
    }
    
    deinit {
        systemQuery.stop()
        localQuery.stop()
    }
    
    private func startQuery(
        _ query: inout NSMetadataQuery,
        `in`: FileManager.SearchPathDomainMask,
        completion: @escaping @Sendable (Notification) -> ()
    ) {
        query.predicate = NSPredicate(format: "kMDItemContentType == 'com.apple.application-bundle'")
        if let appFolder = FileManager.default.urls(
            for: .allApplicationsDirectory,
            in: `in`
        ).first {
            query.searchScopes = [appFolder]
        }
        
        NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidFinishGathering,
            object: nil,
            queue: nil,
            using: completion
        )
        
        query.start()
    }
    
    private func queryDidFinishGathering(
        _ query: NSMetadataQuery, to: inout [InstalledApp],
        notification: Notification
    ) {
        if let items  = query.results as? [NSMetadataItem] {
            to = items.compactMap { item in
                guard
                    let bundleId = item.value(forAttribute: NSMetadataItemCFBundleIdentifierKey) as? String,
                    let displayName = item.value(forAttribute: NSMetadataItemDisplayNameKey) as? String,
                    let path = item.value(forAttribute: NSMetadataItemPathKey) as? String,
                    let installationFolder = URL(string: path)?.deletingLastPathComponent().absoluteString.removingPercentEncoding
                else {
                    return nil
                }
                
                let icon = NSWorkspace.shared.icon(forFile: path)
                return .init(
                    bundleID: bundleId,
                    icon: icon,
                    displayName: displayName,
                    installationFolder: installationFolder
                )
            }
        }
    }
    
    private func ensureFinderApp() {
        let finderBundleID = "com.apple.finder"
        
        if !systemApps.contains(where: { $0.bundleID == finderBundleID }) {
            let finderPath = "/System/Library/CoreServices/Finder.app"
            let icon = NSWorkspace.shared.icon(forFile: finderPath)
            let displayName = FileManager.default.displayName(atPath: finderPath)
            let installationFolder = (finderPath as NSString).deletingLastPathComponent
            
            let finderApp = InstalledApp(
                bundleID: finderBundleID,
                icon: icon,
                displayName: displayName,
                installationFolder: installationFolder
            )
            self.systemApps.append(finderApp)
        }
    }
    
    func displayName(for bundleID: String) -> String? {
        return (systemApps + installedApps).first { $0.bundleID == bundleID }?.displayName
    }
}
