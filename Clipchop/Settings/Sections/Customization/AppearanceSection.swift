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
    
    @State var isRestartAlertPresented: Bool = false
    
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
            Picker(selection: $colorStyle) {
                Text(Bundle.main.appName)
                    .tag(ColorStyle.app)
                
                Text("System")
                    .tag(ColorStyle.system)
                
                Text("Custom")
                    .tag(ColorStyle.custom)
            } label: {
                HStack {
                    Text("Color style")
                    
                    if !DefaultsStack.shared.isUnchanged(.accentColor) {
                        Button {
                            isRestartAlertPresented = true
                        } label: {
                            Text("Requires Relaunch")
                            Image(systemSymbol: .powerCircleFill)
                        }
                        .buttonStyle(.borderless)
                        .buttonBorderShape(.capsule)
                        .tint(.red)
                    }
                    
                    Spacer()
                    
                    if colorStyle == .custom {
                        ColorPicker(selection: $customAccentColor) {
                            
                        }
                    }
                }
            }
            .alert("Relaunch \(Bundle.main.appName)", isPresented: $isRestartAlertPresented) {
                Button("Relaunch", role: .destructive) {
                    relaunch()
                }
            } message: {
                Text("Relaunch \(Bundle.main.appName) to apply the accent color?")
            }
        }
    }
}

#Preview {
    previewSection {
        AppearanceSection()
    }
}
