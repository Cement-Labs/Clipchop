//
//  CategorizationPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/26.
//

import SwiftUI
import Defaults

struct CategorizationPage: View {
    @Default(.categories) var categories
    
    var body: some View {
        ListEmbeddedForm {
            Section {
                NavigationStack {
                    NavigationLink {
                        ListEmbeddedForm {
                            CategoryListSection()
                                .navigationTitle("Categories")
                        }
                    } label: {
                        Text("Categories")
                            .badge(categories.count)
                    }
                }
            }
            
            FileTypeListSection()
        }
    }
}
