//
//  LuminareAboutSettings.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/28.
//

import SwiftUI
import Defaults
import Luminare
import SFSafeSymbols

struct LuminareAboutSettings: View {
    @State private var isHoverAppVersion = false
    
    var body: some View {
        LuminareSection {
            Button {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(rawVersion, forType: .string)
            } label: {
                HStack {
                    Image(nsImage: AppIcon.currentAppIcon.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Bundle.main.appName)
                            .fontWeight(.medium)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            CopyrightsView()
                            HStack {
                                Image(systemSymbol: isHoverAppVersion ? .infoCircle : .paperclipCircle)
                                Text(isHoverAppVersion ?
                                     semanticVersion :  Defaults[.timesClipped] >= 1_000_000 ?
                                    .init(localized: "note", defaultValue: "You've clipped… uhh… I… lost count…") :
                                    .init(localized: "note2", defaultValue: "You've already clipped \(Defaults[.timesClipped]) times!")
                                )
                                .monospaced()
                                .foregroundStyle(.secondary)
                                .contentTransition(.numericText(countsDown: !isHoverAppVersion))
                                .animation(LuminareSettingsWindow.animation, value: isHoverAppVersion)
                                .animation(LuminareSettingsWindow.animation, value: Defaults[.timesClipped])
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(4)
            }
            .buttonStyle(LuminareCosmeticButtonStyle(Image(systemSymbol: .clipboard)))
            .onHover { isOnHover in
                isHoverAppVersion = isOnHover
            }
        }
        
        LuminareSection {
            Text(
                "Clipchop is currently still a very early version, and many things are not yet mature. Therefore, we really need you to share your feedback on GitHub, including feature suggestions, interaction recommendations, and bug reports."
            )
            .foregroundStyle(.secondary)
            .font(.callout)
            .padding(8)

            HStack(spacing: 2) {
                Button("FeedBack") {
                    if let url = URL(string: "https://github.com/Cement-Labs/Clipchop/issues") {
                        NSWorkspace.shared.open(url)
                    }
                }

                Button("Source Code") {
                    if let url = URL(string: "https://github.com/Cement-Labs/Clipchop") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
        LuminareSection("Acknowledgements") {
            LuminareAcknowledgementsView()
        }
    }
}
