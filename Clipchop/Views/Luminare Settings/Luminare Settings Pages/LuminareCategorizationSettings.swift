//
//  LuminareCategorizationSettings.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/27.
//

import SwiftUI
import Luminare
import Defaults
import UniformTypeIdentifiers

struct LuminareCategorizationSettings: View {
    
    @Default(.categories) var categories
    @Default(.allTypes) var allTypes
    
    @State private var showCategorizationSheet = false
    
    var body: some View {
        LuminareSection("You have collected \(allTypes.count) types of files") {
            VStack {
                Button("Edit") {
                    showCategorizationSheet.toggle()
                }
                .sheet(isPresented: $showCategorizationSheet) {
                    CategorizationSection()
                        .frame(width: 600, height: 500)
                }
            }
            ForEach(categories, id: \.name) { category in
                HStack {
                    Text("\(category.name)")
                    Spacer()
                    Text("\(category.types.count)")
                        .frame(maxWidth: 150)
                        .clipShape(.capsule)
                        .monospaced()
                        .fixedSize()
                        .padding(4)
                        .padding(.horizontal, 4)
                        .background {
                            ZStack {
                                Capsule()
                                    .strokeBorder(.quaternary, lineWidth: 1)
                                
                                Capsule()
                                    .foregroundStyle(.quinary.opacity(0.5))
                            }
                        }
                }
                .padding(.horizontal, 8)
                .padding(.trailing, 2)
                .frame(minHeight: 34,alignment: .leading)
            }
        }
    }
}
