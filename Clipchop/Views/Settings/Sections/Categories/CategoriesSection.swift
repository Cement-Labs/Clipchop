//
//  CategoriesSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/28.
//

import SwiftUI
import Defaults

struct CategoriesSection: View {
    @Default(.fileTypes) private var fileTypes
    
    var body: some View {
        FormSectionList {
            NavigationStack {
                List {
                    ForEach(fileTypes.sorted()) { type in
                        NavigationLink {
                            List {
                                ForEach(type.categories.sorted()) { category in
                                    Text(category.name)
                                }
                            }
                        } label: {
                            Text(type.ext)
                                .monospaced()
                            
                            Spacer()
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(type.categories.sorted()) { category in
                                        TagView(style: .quinary) {
                                            Text(category.name)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            .aspectRatio(contentMode: .fit)
                            
                            Image(systemSymbol: .chevronForward)
                                .foregroundStyle(.secondary)
                        }
                        .padding(4)
                    }
                }
            }
        }
    }
}
