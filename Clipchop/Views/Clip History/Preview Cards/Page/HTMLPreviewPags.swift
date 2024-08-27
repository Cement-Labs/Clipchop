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
        
        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                html, body {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100%;
                    display: flex;
                    font-size: 15px;
                    align-items: center;
                    justify-content: center;
                    line-height: 1.2;
                    box-sizing: border-box;
                    font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; 
                }
                body {
                    padding: 10px;
                    text-align: center;
                    overflow: auto;
                }
                .content {
                    width: 100%;
                    max-width: 100%;
                    height: auto;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    text-align: center;
                    flex-wrap: wrap;
                    overflow-wrap: break-word; 
                    word-wrap: break-word;
                    word-break: break-all;
                }
            </style>
        </head>
        <body>
            <div class="content">
                \(htmlContent)
            </div>
        </body>
        </html>
        """
        
        nsView.loadHTMLString(htmlString, baseURL: nil)
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
        ZStack {
            WebView(htmlContent: htmlContent)
                .allowsHitTesting(false)
                .background(backgroundColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
