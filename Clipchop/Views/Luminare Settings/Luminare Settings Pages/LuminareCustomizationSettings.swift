//
//  LuminareCustomizationSettings.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/27.
//

import SwiftUI
import Luminare
import Defaults
import SFSafeSymbols

struct LuminareCustomizationSettings: View {
    
    @Default(.timesClipped) private var timesClipped
    @Default(.appIcon) private var appIcon
    @Default(.clipSound) private var clipSound
    @Default(.pasteSound) private var pasteSound
    @Default(.colorStyle) private var colorStyle
    @Default(.customAccentColor) private var customAccentColor
    
    var body: some View {
        
        LuminareSection("Appearance") {
            LuminarePicker(
                elements: AppIcon.unlockedAppIcons,
                selection: $appIcon
            ) { icon in
                HStack {
                    Image(nsImage: icon.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tag(icon.assetName)
                .padding()
            }
            .onChange(of: appIcon) { _, newIcon in
                newIcon.setAppIcon()
            }
            Button("Suggest new icon") {
                if let url = URL(string: "https://github.com/Cement-Labs/Clipchop/issues/new/choose") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        
        LuminareSection() {
            soundPicker("Clip sound", selection: $clipSound) { _, newSound in
                newSound.setClipSound()
                newSound.play()
            }
            
            soundPicker("Paste sound", selection: $pasteSound) { _, newSound in
                newSound.setPasteSound()
                newSound.play()
            }
        }
        
        LuminareSection("Color") {
            HStack {
                Text("Preferred color scheme")
                Spacer()
                LuminarePreferredColorSchemePicker()
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 42)
            LuminarePicker(
                elements: ColorStyle.allCases,
                selection: $colorStyle,
                columns: 3
            ) { style in
                VStack {
                    switch style {
                    case .app:
                        ColoredPickerRowVStack(style: Defaults.inlineAccentColor(style: .app, customColor: .accent)) {
                            Text("Application")
                        }
                    case .system:
                        ColoredPickerRowVStack(style: Defaults.inlineAccentColor(style: .system, customColor: .blue)) {
                            Text("macOS Blue")
                        }
                    case .custom:
                        ColoredPickerRowVStack(style: Defaults.inlineAccentColor(style: .custom, customColor: customAccentColor)) {
                            Text("Custom")
                        }
                    }
                }
                .frame(minHeight: 66)
            }
            if colorStyle == .custom {
                LuminareColorPicker(
                    color:  $customAccentColor,
                    colorNames: (red: "Red", green: "Green", blue: "Blue")
                )
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
            Text(titleKey)
            
            Spacer()
            
            CustomLuminarePicker(selection: selection, items: Sound.unlockedSounds) { sound in
                sound.name ?? ""
            }
            .frame(width: 80, height: 24, alignment: .trailing)
            .controlSize(.regular)
            .onChange(of: selection.wrappedValue, perform: { newValue in
                action(newValue, selection.wrappedValue)
            })
            
            if selection.wrappedValue.hasSound {
                Button {
                    selection.wrappedValue.play()
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.trailing, 2)
        .frame(minHeight: 42)
    }
}
