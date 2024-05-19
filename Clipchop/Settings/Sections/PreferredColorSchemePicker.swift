//
//  PreferredColorSchemePicker.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/19.
//

import SwiftUI
import Defaults

struct PreferredColorSchemePicker: View {
    @Default(.preferredColorScheme) var preferredColorScheme
    
    var body: some View {
        Picker("Preferred color scheme", selection: $preferredColorScheme) {
            Text("System")
                .tag(PreferredColorScheme.system)
            
            Divider()
            
            Text("Light")
                .tag(PreferredColorScheme.light)
            
            Text("Dark")
                .tag(PreferredColorScheme.dark)
        }
    }
}
