//
//  MenuBarIconView.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import SFSafeSymbols
import Defaults

struct MenuBarIconView: View {
    @Default(.timesClipped) var timesClipped
    
    var body: some View {
        Image(.clipchopFill)
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 18)
        
            .symbolEffect(.bounce, value: timesClipped)
            .onReceive(.didClip) { _ in
                Sound.currentSound.play()
                timesClipped += 1
            }
    }
}
