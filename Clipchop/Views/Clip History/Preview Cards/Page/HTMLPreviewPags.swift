//
//  HtmlPreviewPags.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/8.
//

import SwiftUI
import Defaults
import AppKit
import WebKit

struct WebView: NSViewRepresentable {
    let htmlContent: String

    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

struct HTMLPreviewPage: View {
    let htmlContent: String
    let backgroundColor: Color
    
    init(htmlData: Data?, colorScheme: ColorScheme) {
        if let htmlData = htmlData,
           let htmlString = String(data: htmlData, encoding: .utf8) {
            self.htmlContent = htmlString
            self.backgroundColor = HTMLPreviewPage.extractBackgroundColor(from: htmlString, colorScheme: colorScheme)
        } else {
            self.htmlContent = ""
            self.backgroundColor = .white
        }
    }

    static func extractBackgroundColor(from htmlString: String, colorScheme: ColorScheme) -> Color {
        // Basic background color handling based on color scheme
        return colorScheme == .dark ? .black : .white
    }

    var body: some View {
        WebView(htmlContent: htmlContent)
            .allowsHitTesting(false)
            .background(backgroundColor)
            .frame(width: Defaults[.displayMore] ? 112 : 80, height: Defaults[.displayMore] ? 112 : 80)
    }
}
