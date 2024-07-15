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
    @Default(.timesClipped) private var timesClipped
    @Default(.appIcon) private var appIcon
    @Default(.clipSound) private var clipSound
    @Default(.pasteSound) private var pasteSound
 
    @Default(.colorStyle) private var colorStyle
    @Default(.customAccentColor) private var customAccentColor
    
    @Environment(\.hasTitle) private var hasTitle
    
    var body: some View {
        if hasTitle {
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
                withCaption {
                    Text("Appearance")
                } caption: {
                    Text("""
Clip more to unlock more! You've already clipped \(timesClipped) times.
""")
                    .contentTransition(.numericText(value: Double(timesClipped)))
                    .animation(.snappy(duration: 0.5), value: timesClipped)
                }
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
        
        Section {
            withCaption("Custom accent color only applies to the clip history window.") {
                Picker(selection: $colorStyle) {
                    ColoredPickerRow(style: Defaults.inlineAccentColor(style: .app, customColor: .accent)) {
                        Text("Application")
                    }
                    .tag(ColorStyle.app)
                    
                    ColoredPickerRow(style: Defaults.inlineAccentColor(style: .system, customColor: .blue)) {
                        Text("macOS Blue")
                    }
                    .tag(ColorStyle.system)
                    
                    ColoredPickerRow(style: Defaults.inlineAccentColor(style: .custom, customColor: customAccentColor)) {
                        Text("Custom")
                    }
                    .tag(ColorStyle.custom)
                } label: {
                    HStack {
                        Text("Color style")
                        
                        Spacer()
                        
                        if colorStyle == .custom {
                            ColorPicker(selection: $customAccentColor) { }
                        }
                    }
                }
            }
            PreferredColorSchemePicker()
        } header: {
            if hasTitle {
                Text("Color")
            }
        }
    }
    
    @ViewBuilder
    private func soundPicker(
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
}
