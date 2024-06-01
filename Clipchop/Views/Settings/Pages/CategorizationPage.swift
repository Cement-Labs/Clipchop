//
//  CategorizationPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/26.
//

import SwiftUI
import Defaults

struct CategorizationPage: View {
    @Default(.fileTypes) private var fileTypes
    
    @State private var searchQuery: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width <= 820 {
                // Compact layout
                ListEmbeddedForm {
                    Section {
                        NavigationStack {
                            NavigationLink {
                                ListEmbeddedForm {
                                    FileTypeListSection(searchQuery: $searchQuery)
                                        .navigationTitle("File Types")
                                }
                                .navigationSplitViewCollapsingDisabled()
                            } label: {
                                Text("File Types")
                                    .badge(fileTypes.count)
                            }
                        }
                    }
                    
                    CategoryListSection(searchQuery: $searchQuery)
                }
            } else {
                // Wide layout
                HSplitView {
                    ListEmbeddedForm {
                        CategoryListSection(searchQuery: $searchQuery)
                            .environment(\.hasTitle, false)
                            .environment(\.isSearchable, false)
                    }
                    .frame(minWidth: 370, idealWidth: 370)
                    
                    ListEmbeddedForm {
                        FileTypeListSection(searchQuery: $searchQuery)
                    }
                    .frame(minWidth: 420)
                }
            }
        }
    }
}
