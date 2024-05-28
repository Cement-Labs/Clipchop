//
//  CategoriesPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/26.
//

import SwiftUI

struct CategoriesPage: View {
    var body: some View {
        ListEmbeddedForm {
            CategoriesSection()
        }
    }
}

#Preview {
    previewPage {
        CategoriesPage()
    }
}
