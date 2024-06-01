//
//  CategorizationPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/26.
//

import SwiftUI
import Defaults

struct CategorizationPage: View {
    @Default(.fileTypes) var fileTypes
    
    var body: some View {
        ListEmbeddedForm {
            Section {
                NavigationStack {
                    NavigationLink {
                        ListEmbeddedForm {
                            FileTypeListSection()
                                .navigationTitle("File Types")
                        }
                        .navigationSplitViewCollapsingDisabled()
                    } label: {
                        Text("File Types")
                            .badge(fileTypes.count)
                    }
                }
            }
            
            CategoryListSection()
        }
    }
}
