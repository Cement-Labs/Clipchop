//
//  LifecycleHandler.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/25.
//

import Foundation
import SwiftUI

func quit() {
    NSApp.terminate(nil)
}

// https://stackoverflow.com/questions/29847611/restarting-osx-app-programmatically
func relaunch() {
    let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
    let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
    let task = Process()
    
    task.launchPath = "/usr/bin/open"
    task.arguments = [path]
    task.launch()
    
    quit()
}
