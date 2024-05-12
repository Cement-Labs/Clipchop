//
//  AppearanceSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import SwiftUI
import Defaults
import SFSafeSymbols

struct AppearanceSection: View {
    @Default(.timesClipped) var timesClipped
    @Default(.appIcon) var appIcon
    @Default(.sound) var sound
    
    @Default(.useCustomAccentColor) var useCustomAccentColor
    @Default(.customAccentColor) var customAccentColor
    
    var body: some View {
        Section {
            Picker("App icon", selection: $appIcon) {
                ForEach(Icons.unlockedIcons, id: \.self) { icon in
                    HStack {
                        Image(nsImage: icon.image)
                        Text(icon.name ?? "")
                    }
                    .tag(icon.assetName)
                }
            }
            .onChange(of: appIcon) { oldIcon, newIcon in
                Icons.setAppIcon(to: newIcon)
            }
            
            HStack {
                Picker("Clip sound", selection: $sound) {
                    ForEach(Sounds.unlockedSounds, id: \.self) { sound in
                        Text(sound.name ?? "")
                            .tag(sound.assetName)
                    }
                }
                .onChange(of: sound) { oldSound, newSound in
                    Sounds.setSound(to: newSound)
                }
                
                if sound.hasSound {
                    Button {
                        sound.play()
                    } label: {
                        Image(systemSymbol: .speakerWave2Fill)
                    }
                    .buttonStyle(.plain)
                }
            }
        } header: {
            Text("Appearance")
        } footer: {
            description {
                Text("""
Clip more to unlock more! You've already clipped \(timesClipped) times.
""")
            }
            .padding(.horizontal, 8)
            
            Spacer()
        }
        
        Section {
            Toggle("Use custom accent color", isOn: $useCustomAccentColor)
            
            if useCustomAccentColor {
                ColorPicker("Custom accent color", selection: $customAccentColor, supportsOpacity: false)
            }
        }
    }
}

#Preview {
    Form {
        AppearanceSection()
    }
    .formStyle(.grouped)
}
