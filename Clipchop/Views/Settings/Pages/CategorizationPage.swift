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
    @State private var isCategoriesSearchable: Bool = true
    @State private var isFileTypesSearchable: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width <= 820 {
                // Compact layout
                ListEmbeddedForm {
                    Section {
                        NavigationStack {
                            NavigationLink {
                                ListEmbeddedForm {
                                    FileTypeTagCloudSection(searchQuery: $searchQuery)
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
                            .environment(\.alternatingLayout, true)
                            .environment(\.isSearchable, isCategoriesSearchable)
                    }
                    .frame(minWidth: 370, idealWidth: 370)
                    .toolbar {
                        ToolbarItemGroup(placement: .status) {
                            // Trigger the layout where the search bar is at the rightmost
                            Spacer()
                        }
                    }
                    
                    ListEmbeddedForm {
                        FileTypeTagCloudSection(searchQuery: $searchQuery)
                            .environment(\.hasTitle, false)
                            .environment(\.alternatingLayout, true)
                            .environment(\.isSearchable, isFileTypesSearchable)
                    }
                    .frame(minWidth: 420)
                    .toolbar {
                        ToolbarItemGroup(placement: .primaryAction) {
                            Spacer()
                            
                            Button {
                                isCategoriesSearchable.toggle()
                            } label: {
                                Image(systemSymbol: isCategoriesSearchable ? .listBulletRectangleFill : .listBulletRectangle)
                            }
                            .help(isCategoriesSearchable ? "Currently search for categories" : "Currently don't search for categories")
                            
                            Button {
                                isFileTypesSearchable.toggle()
                            } label: {
                                Image(systemSymbol: isFileTypesSearchable ? .tagFill : .tag)
                            }
                            .help(isCategoriesSearchable ? "Currently search for file types" : "Currently don't search for file types")
                        }
                    }
                }
            }
        }
    }
}
