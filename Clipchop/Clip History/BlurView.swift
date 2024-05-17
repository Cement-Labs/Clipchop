//
//  BlurView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/17.
//

import SwiftUI

struct BlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let blurView = NSVisualEffectView(frame: .zero)
        
        blurView.blendingMode = NSVisualEffectView.BlendingMode.behindWindow
        blurView.material = NSVisualEffectView.Material.hudWindow
        blurView.isEmphasized = true
        blurView.state = NSVisualEffectView.State.active
        
        return blurView;
        
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}
