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
    enum Direction {
        case leading
        case trailing
        
        func originalWidth(in geometry: GeometryProxy) -> CGFloat {
            switch self {
            case .leading: .zero
            case .trailing: -geometry.size.width
            }
        }
        
        func horizontalAlignmentGuide(
            width: inout CGFloat,
            height: inout CGFloat,
            spacing: CGFloat,
            lineSpacing: CGFloat,
            in geometry: GeometryProxy,
            isLast: Bool,
            dimensions: ViewDimensions
        ) -> CGFloat {
            switch self {
            case .leading:
                if abs(width - dimensions.width) > geometry.size.width {
                    width = originalWidth(in: geometry)
                    height -= (dimensions.height + lineSpacing)
                }
                
                let result = width
                if isLast {
                    // The last item
                    width = originalWidth(in: geometry)
                } else {
                    width -= (dimensions.width + spacing)
                }
                
                return result
            case .trailing:
                if width + dimensions.width > 0 {
                    width = originalWidth(in: geometry)
                    height -= (dimensions.height + lineSpacing)
                }
                
                let result = width + dimensions.width
                if isLast {
                    // The last item
                    width = originalWidth(in: geometry)
                } else {
                    width += (dimensions.width + spacing)
                }
                
                return result
            }
        }
    }
    
    typealias ViewGenerator = (Model) -> V
    
    var models: [Model]
    var direction: Direction = .leading
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8
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
        var width: CGFloat = direction.originalWidth(in: geometry)
        var height: CGFloat = .zero
        
        HStack(spacing: 0) {
            if direction == .trailing {
                Spacer()
            }
            
            ZStack(alignment: .topLeading) {
                ForEach(models.indices, id: \.self) { index in
                    let model = models[index]
                    viewGenerator(model)
                        .alignmentGuide(.leading) { dimensions in
                            direction.horizontalAlignmentGuide(
                                width: &width, height: &height,
                                spacing: spacing, lineSpacing: lineSpacing,
                                in: geometry, 
                                isLast: model == models.last,
                                dimensions: dimensions
                            )
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
            
            if direction == .leading {
                Spacer()
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
