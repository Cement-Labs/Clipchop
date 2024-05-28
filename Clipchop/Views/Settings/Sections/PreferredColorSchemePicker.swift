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
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var isSheetPresented = false
    
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
        .sheet(isPresented: $isSheetPresented) {
            // To update specific color schemes, like `.system`.
            // Also useful for hiding the inactivate delays between switches.
            ProgressView("Changing Color Scheme")
                .padding()
                .preferredColorScheme(.none)
        }
        .onChange(of: preferredColorScheme) { _, _ in
            isSheetPresented = true
            
            DispatchQueue.main.async  {
                isSheetPresented = false
            }
        }
    }
}
