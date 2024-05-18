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
    @Default(.clipSound) var clipSound
    @Default(.pasteSound) var pasteSound
 
    @Default(.useCustomAccentColor) var useCustomAccentColor
    @Default(.useSystemAccentColor) var useSystemAccentColor
    @Default(.customAccentColor) var customAccentColor
    
    @ViewBuilder
    func soundPicker(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Sound>,
        onChangePerform action: @escaping (Sound, Sound) -> Void
    ) -> some View {
        HStack {
            Picker(titleKey, selection: selection) {
                ForEach(Sound.unlockedSounds, id: \.self) { sound in
                    Text(sound.name ?? "")
                        .tag(sound.assetName)
                }
            }
            .onChange(of: selection.wrappedValue, action)
            
            if selection.wrappedValue.hasSound {
                Button {
                    selection.wrappedValue.play()
                } label: {
                    Image(systemSymbol: .speakerWave2Fill)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    var body: some View {
        Section {
            Picker("App icon", selection: $appIcon) {
                ForEach(AppIcon.unlockedAppIcons, id: \.self) { icon in
                    HStack {
                        Image(nsImage: icon.image)
                        Text(icon.name ?? "")
                    }
                    .tag(icon.assetName)
                }
            }
            .onChange(of: appIcon) { _, newIcon in
                newIcon.setAppIcon()
            }
        }
         
        Section {
            soundPicker("Clip sound", selection: $clipSound) { _, newSound in
                newSound.setClipSound()
                newSound.play()
            }
            
            soundPicker("Paste sound", selection: $pasteSound) { _, newSound in
                newSound.setPasteSound()
                newSound.play()
            }
        } header: {
            withCaption("""
Clip more to unlock more! You've already clipped \(timesClipped) times.
""") {
                Text("Appearance")
            }
        }
        
        Section {
            Toggle(isOn: $useCustomAccentColor) {
                HStack(alignment: .center) {
                    Text("Custom accent color")
                    
                    ColorPicker(selection: $customAccentColor, supportsOpacity: false) {
                        
                    }
                    .controlSize(.mini)
                    .disabled(!useCustomAccentColor || useSystemAccentColor)
                    .opacity(!useCustomAccentColor || useSystemAccentColor ? 0.5 : 1)
                    
                    Spacer()
                    
                    Picker(selection: $useSystemAccentColor) {
                        Text("System")
                            .tag(true)
                        
                        Text("Custom")
                            .tag(false)
                    } label: {
                        
                    }
                    .disabled(!useCustomAccentColor)
                }
            }
        }
    }
}

#Preview {
    previewSection {
        AppearanceSection()
    }
}
