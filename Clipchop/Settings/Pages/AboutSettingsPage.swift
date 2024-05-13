//
//  AboutSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI

struct AboutSettingsPage: View {
    var body: some View {
        HStack {
            Spacer()
            
            Image(nsImage: Icons.currentAppIcon.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)

            VStack(alignment: .leading, spacing: 16) {
                Text(Bundle.main.appName)
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 4) {
                    AppVersionView()
                    CopyrightsView()
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    AboutSettingsPage()
}
