//
//  WrappingHStack.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import SwiftUI
import UniformTypeIdentifiers

// Originally by https://stackoverflow.com/a/65453108/23452915
struct WrappingHStack<Model, V>: View where Model: Hashable, V: View {
    typealias ViewGenerator = (Model) -> V
    
    var models: [Model]
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8
    var mirrored: Bool = false
    var viewGenerator: ViewGenerator
    
    @State private var size: CGSize = .zero
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                generateContent(in: geometry)
            }
        }
        .frame(height: size.height)
    }
    
    @ViewBuilder
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        ZStack(alignment: .topLeading) {
            ForEach(models, id: \.self) { model in
                viewGenerator(model)
                    .alignmentGuide(.leading) { dimensions in
                        if width + dimensions.width > geometry.size.width {
                            width = 0
                            height -= (dimensions.height + lineSpacing)
                        }
                        
                        let result = -width
                        if model == models.last {
                            // The last item
                            width = 0
                        } else {
                            width += (dimensions.width + spacing)
                        }
                        
                        return result
                    }
                    .alignmentGuide(.top) { dimensions in
                        let result = height
                        if model == models.last {
                            // The last item
                            height = 0
                        }
                        
                        return result
                    }
            }
        }
        .background {
            viewSizeReader($size)
        }
    }
    
    @ViewBuilder
    private func viewSizeReader(_ size: Binding<CGSize>) -> some View {
        GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            
            DispatchQueue.main.async {
                size.wrappedValue = rect.size
            }
            
            return .clear
        }
    }
}
