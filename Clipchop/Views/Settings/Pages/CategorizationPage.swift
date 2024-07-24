//
//  CategoriesPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/26.
//

import SwiftUI
import Defaults
import SFSafeSymbols
import UniformTypeIdentifiers

struct CategorizationPage: View {
    var body: some View {
        ZStack {
            List { }
            .allowsHitTesting(false)
            .scrollDisabled(true)
            .ignoresSafeArea()
            
            CategorizationSection()
                .background(.clear)
                .scrollContentBackground(.hidden)
        }
    }
}

