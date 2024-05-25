//
//  RTFPreviewPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/21.
//

import SwiftUI

struct RTFPreviewPage: View {
    let attributedText: AttributedString
    
    init(rtfData: Data?) {
        if 
            let rtfData = rtfData,
            let contents = NSAttributedString(rtf: rtfData, documentAttributes: nil)
        {
            attributedText = .init(contents)
        } else {
            attributedText = .init()
        }
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
