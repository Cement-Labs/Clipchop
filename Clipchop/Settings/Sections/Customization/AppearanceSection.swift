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
 
    @Default(.colorStyle) var colorStyle
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
        } header: {
            withCaption("""
Clip more to unlock more! You've already clipped \(timesClipped) times.
""") {
                Text("Appearance")
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
        }
        ColoredPickerRow(Defaults.inlineAccentColor(style: .system, customColor: .clear)) {
            
        }
        
        Section("Color") {
            withCaption("Custom accent color only applies to the clip history window.") {
                Picker(selection: $colorStyle) {
                    ColoredPickerRow(Defaults.inlineAccentColor(style: .app, customColor: .clear)) {
                        Text("Application")
                    }
                    .tag(ColorStyle.app)
                    
                    ColoredPickerRow(Defaults.inlineAccentColor(style: .system, customColor: .clear)) {
                        Text("macOS Blue")
                    }
                    .tag(ColorStyle.system)
                    
                    ColoredPickerRow(Defaults.inlineAccentColor(style: .custom, customColor: customAccentColor)) {
                        Text("Custom")
                    }
                    .tag(ColorStyle.custom)
                } label: {
                    HStack {
                        Text("Color style")
                        
                        Spacer()
                        
                        if colorStyle == .custom {
                            ColorPicker(selection: $customAccentColor) {
                                
                            }
                        }
                    }
                }
            }
            
            PreferredColorSchemePicker()
        }
    }
}

#Preview {
    previewSection {
        AppearanceSection()
    }
}
