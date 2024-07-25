//
//  RTFPreviewPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/21.
//

import SwiftUI
import Defaults
import AppKit

struct RTFPreviewPage: View {
    
    let attributedText: AttributedString
    let backgroundColor: Color
    
    static func dynamicColor(for colorScheme: ColorScheme) -> NSColor {
        return colorScheme == .dark ? .black : .white
    }

    init(rtfData: Data?, colorScheme: ColorScheme) {
        if
            let rtfData = rtfData,
            let contents = NSAttributedString(rtf: rtfData, documentAttributes: nil)
        {
            attributedText = .init(contents)
            backgroundColor = RTFPreviewPage.extractBackgroundColor(from: contents, colorScheme: colorScheme)
        } else {
            attributedText = .init()
            backgroundColor = .white
        }
    }
    
    static func extractBackgroundColor(from attributedString: NSAttributedString, colorScheme: ColorScheme) -> Color {
        var backgroundColor: NSColor = dynamicColor(for: colorScheme)
        attributedString.enumerateAttribute(.backgroundColor, in: NSRange(location: 0, length: attributedString.length)) { value, _, _ in
            if let color = value as? NSColor {
                backgroundColor = color
                return
            }
        }
        return Color(backgroundColor)
    }
        
    var body: some View {
        VStack(alignment: .center){
            Text(attributedText)
                .font(.system(size: 12))
                .minimumScaleFactor(0.8)
                .lineLimit(10)
                .fixedSize(horizontal: false, vertical: false)
                .background(Color.clear)
                .padding(.all, 4)
        }
        .frame(width: Defaults[.displayMore] ? 112 : 80, height: Defaults[.displayMore] ? 112 : 80)
        .background(backgroundColor)
    }
}
