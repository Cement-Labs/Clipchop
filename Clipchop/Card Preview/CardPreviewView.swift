//
//  CardPreviewView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/19.
//

import SwiftUI

struct CardPreviewView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isSelected = false
    @State private var data: Data?
    
    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var body: some View {
        ZStack {
            ZStack {
                
            }
        }
    }
}

#Preview {
    CardPreviewView()
}
