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
    @Default(.timesClipped) private var timesClipped
    
    var body: some View {
        Image(.clipchopFill)
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 18)
        
            .symbolEffect(.bounce, value: timesClipped)
            .onReceive(.didClip) { _ in
                if !Defaults[.dnd] {
                    Sound.defaultClipSound.play()
                }
                timesClipped += 1
            }
            .onReceive(.didPaste) { _ in
                if !Defaults[.dnd] {
                    Sound.defaultPasteSound.play()
                }
            }
    }
}
