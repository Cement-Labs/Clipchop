//
//  FileTypeListView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import SwiftUI

struct FileTypeListView<Label>: View where Label: View {
    @ViewBuilder var label: () -> Label
    
    @Binding var types: [String]
    
    @State private var totalHeight: CGFloat = .zero
    
    init(
        types: Binding<[String]>,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label
        self._types = types
    }
    
    init(
        _ titleKey: LocalizedStringKey,
        types: Binding<[String]>
    ) where Label == Text {
        self.init(types: types) {
            Text(titleKey)
        }
    }
    
    var body: some View {
        Section {
            VStack {
                GeometryReader { geometry in
                    generateContent(in: geometry)
                }
            }
            .frame(height: totalHeight)
        } header: {
            label()
        }
    }
    
    // Originally by https://stackoverflow.com/a/65453108/23452915
    @ViewBuilder
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = .zero
        var height: CGFloat = .zero
        
        ZStack(alignment: .topLeading) {
            ForEach(types, id: \.self) { type in
                FileTypeTagView(type: type)
                    .onDrag {
                        NSItemProvider(object: type as NSString)
                    }
                
                    .alignmentGuide(.leading) { dimensions in
                        if abs(width - dimensions.width) > geometry.size.width {
                            width = 0
                            height -= dimensions.height
                        }
                        
                        let result = width
                        if type == types.last {
                            // The last item
                            width = 0
                        } else {
                            width -= dimensions.width
                        }
                        
                        return result
                    }
                    .alignmentGuide(.top) { dimensions in
                        let result = height
                        if type == types.last {
                            // The last item
                            height = 0
                        }
                        
                        return result
                    }
            }
        }
        .background {
            viewHeightReader($totalHeight)
        }
    }
    
    @ViewBuilder
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
