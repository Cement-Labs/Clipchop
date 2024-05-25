//
//  ColoredPickerRow.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/19.
//

import SwiftUI

struct ColoredPickerRow<Style, Content>: View where Style: ShapeStyle, Content: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.displayScale) var displayScale
    
    let style: Style
    let content: () -> Content
    
    init(_ style: Style, @ViewBuilder content: @escaping () -> Content) {
        self.style = style
        self.content = content
    }
    
    var body: some View {
        HStack(alignment: .center) {
            render {
                ZStack {
                    Image(systemSymbol: .circleFill)
                        .foregroundStyle(colorScheme == .light ? .white.opacity(0.75) : .black.opacity(0.75))
                    
                    Circle()
                        .foregroundStyle(style)
                        .padding(3.5)
                }
            }
            
            content()
        }
    }
    
    @MainActor
    func render(content: () -> some View) -> Image? {
        let renderer = ImageRenderer(content: content())
        renderer.scale = displayScale
        
        if let image = renderer.nsImage {
            return Image(nsImage: image)
        } else {
            return nil
        }
    }
}
