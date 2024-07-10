//
//  HtmlPreviewPags.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/8.
//

import SwiftUI
import AppKit

struct HTMLPreviewPage: View {
        
    let attributedText: AttributedString
    let backgroundColor: Color
    
    static func dynamicColor(for colorScheme: ColorScheme) -> NSColor {
        return colorScheme == .dark ? .black : .white
    }
    
    init(htmlData: Data?, colorScheme: ColorScheme) {
        if let htmlData = htmlData,
           let contents = HTMLPreviewPage.attributedString(from: htmlData) {
            let adjustedContents = HTMLPreviewPage.adjustFonts(in: contents)
            attributedText = AttributedString(adjustedContents)
            backgroundColor = HTMLPreviewPage.extractBackgroundColor(from: adjustedContents, colorScheme: colorScheme)
        } else {
            attributedText = AttributedString()
            backgroundColor = .white
        }
    }
    
    static func attributedString(from htmlData: Data) -> NSAttributedString? {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil) else {
            return nil
        }
        
        return attributedString
    }
    
    static func extractBackgroundColor(from attributedString: NSAttributedString, colorScheme: ColorScheme) -> Color {
        let backgroundColor: NSColor = dynamicColor(for: colorScheme)
//        attributedString.enumerateAttribute(.backgroundColor, in: NSRange(location: 0, length: attributedString.length)) { value, _, _ in
//            if let color = value as? NSColor {
//                backgroundColor = color
//                return
//            }
//        }
        return Color(backgroundColor)
    }
    
    static func adjustFonts(in attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        let defaultFont = NSFont.systemFont(ofSize: 12)
        
        mutableAttributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length)) { value, range, _ in
            mutableAttributedString.addAttribute(.font, value: defaultFont, range: range)
        }
        
        return mutableAttributedString
    }

    var body: some View {
        VStack(alignment: .center) {
            Text(attributedText)
                .font(.system(size: 12))
                .minimumScaleFactor(0.8)
                .lineLimit(10)
                .fixedSize(horizontal: false, vertical: false)
                .background(backgroundColor)
                .padding(.all, 10)
        }
        .frame(width: 80, height: 80)
        .background(backgroundColor)
    }
}
