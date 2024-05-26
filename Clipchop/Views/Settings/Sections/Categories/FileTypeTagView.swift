//
//  FileTypeTagView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import SwiftUI

struct FileTypeTagView: View {
    var type: String
    var onDelete: (String) -> Void
    
    @State private var isDeleteButtonShown: Bool = false
    
    var body: some View {
        Text(type)
            .monospaced()
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        
            .background {
                VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
            }
            .clipShape(.rect(cornerRadius: 12))
        
            .onAppear {
                // Hold option to show delete button
                NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                    isDeleteButtonShown = event.modifierFlags.contains(.option)
                    return event
                }
            }
    }
}
