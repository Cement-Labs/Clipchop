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
                            HStack {
                                Text(type.ext)
                                    .monospaced()
                                
                                Spacer()
                                
                                WrappingHStack(models: type.categories.sorted(), mirrored: true) { category in
                                    TagView(style: .quinary) {
                                        Text(category.name)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                //.aspectRatio(contentMode: .fit)
                                .background(.red)
                                
                                Image(systemSymbol: .chevronForward)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(4)
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
    }
}
