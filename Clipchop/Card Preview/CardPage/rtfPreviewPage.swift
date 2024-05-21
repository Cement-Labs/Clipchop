//
//  RTFView.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/21.
//

import SwiftUI

struct rtfPreviewPage: View {
    
    let attributedText: AttributedString
    
    init(rtfData: Data?) {
        var text = AttributedString("empty")
        if let rtfData = rtfData,
           let contents = NSAttributedString(rtf: rtfData, documentAttributes: nil) {
            text = AttributedString(contents)
        }
        attributedText = text
    }
    
    var body: some View {
        VStack(alignment: .center){
            Text(attributedText)
                .font(.system(size: 12).monospaced())
                .minimumScaleFactor(0.8)
                .lineLimit(10)
                .fixedSize(horizontal: false, vertical: false)
                .background(.clear)
        }
        .frame(width: 70, height: 70)
    }
}
