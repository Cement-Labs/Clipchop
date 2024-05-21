//
//  CardPreviewView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/19.
//

import SwiftUI
import SwiftData
import Defaults

struct CardPreviewView: View {
    
//    @Query private var items: []
    
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
                VStack{
//                    PreviewContentView(clipboardHistory: )
                }
                .allowsHitTesting(false)
                .frame(width: 80, height: 80, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 12.5))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.accentColor, lineWidth: 7.5)
        )
        .background(Color.white)
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: Color.accentColor, radius: 10)
    }
}

#Preview {
    CardPreviewView()
}
