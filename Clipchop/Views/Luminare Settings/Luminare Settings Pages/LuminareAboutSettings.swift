//
//  LuminareAboutSettings.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/28.
//

import SwiftUI
import Luminare
import SFSafeSymbols

struct LuminareAboutSettings: View {
    var body: some View {
        LuminareSection {
            HStack {
                Image(nsImage: AppIcon.currentAppIcon.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(Bundle.main.appName)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        AppVersionView()
                        CopyrightsView()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(4)
        }
        
        LuminareSection {
            Text(
                "Clipchop is currently still a very early version, and many things are not yet mature. Therefore, we really need you to share your feedback on GitHub, including feature suggestions, interaction recommendations, and bug reports."
            )
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
            .frame(minHeight: 42)
        }
        LuminareSection("Acknowledgements") {
            LuminareAcknowledgementsView()
            
        }
    }
}
