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

struct CategoriesPage: View {
    var body: some View {
        ListEmbeddedForm {
            CategoriesSection()
        }
    }
}
