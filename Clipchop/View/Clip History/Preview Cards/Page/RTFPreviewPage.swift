//
//  RTFPreviewPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/21.
//

import SwiftUI
import AppKit


struct RTFPreviewPage: View {
    
    let attributedText: AttributedString
    let backgroundColor: Color

    init(rtfData: Data?) {
        if
            let rtfData = rtfData,
            let contents = NSAttributedString(rtf: rtfData, documentAttributes: nil)
        {
            attributedText = .init(contents)
            backgroundColor = RTFPreviewPage.extractBackgroundColor(from: contents)
        } else {
            attributedText = .init()
            backgroundColor = .white
        }
    }
    
    static func extractBackgroundColor(from attributedString: NSAttributedString) -> Color {
        var backgroundColor: NSColor = .clear
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
                .padding(.all, 10)
        }
        .frame(width: 80, height: 80)
        .background(backgroundColor)
    }
}
