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
                    overflow: auto;
                    font-size: 15px; 
                    line-height: 1.2;
                    box-sizing: border-box;
                    font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; 
                }
                body {
                    transform: scale(0.8);
                    transform-origin: 0 0;
                    width: 125%; 
                    height: 125%;
                    word-wrap: break-word;
                    word-break: break-word;
                    white-space: normal;
                }
                @media only screen and (max-width: 600px) {
                    body {
                        font-size: 15px; 
                    }
                }
                @media only screen and (min-width: 601px) and (max-width: 1200px) {
                    body {
                        font-size: 15px; 
                    }
                }
                @media only screen and (min-width: 1201px) {
                    body {
                        font-size: 15px; 
                    }
                }
            </style>
        </head>
        <body>
            \(htmlContent)
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
        WebView(htmlContent: htmlContent)
            .allowsHitTesting(false)
            .background(backgroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
