//
//  HtmlPreviewPags.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/8.
//

import SwiftUI
import Defaults
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
        return Color(backgroundColor)
    }
    
    static func adjustFonts(in attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        let defaultFont = NSFont.systemFont(ofSize: 12)
        let fontManager = NSFontManager.shared
        
        mutableAttributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length)) { value, range, _ in
            if let font = value as? NSFont {
                let fontName = font.fontName
                
                if let systemFont = NSFont(name: fontName, size: font.pointSize), fontManager.availableFonts.contains(systemFont.fontName) {
                    mutableAttributedString.addAttribute(.font, value: systemFont, range: range)
                } else {
                    mutableAttributedString.addAttribute(.font, value: defaultFont, range: range)
                }
            } else {
                mutableAttributedString.addAttribute(.font, value: defaultFont, range: range)
            }
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
                .padding(.all, 4)
        }
        .frame(width: Defaults[.displayMore] ? 112 : 80, height: Defaults[.displayMore] ? 112 : 80)
        .background(backgroundColor)
    }
}
