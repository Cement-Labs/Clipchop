//
//  WebLinkPreviewPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/21.
//

import SwiftUI
import LinkPresentation

class CustomLinkView: LPLinkView {
    override var intrinsicContentSize: CGSize {
        // The most proper size.
        CGSize(width: 128, height: 90)
    }
}

struct WebLinkPreviewPage: NSViewRepresentable {
    typealias NSViewType = CustomLinkView
    var urlString: String
    
    func makeNSView(context: Context) -> CustomLinkView {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL string")
        }

        let linkView = CustomLinkView(frame: .zero)
        linkView.metadata.url = url
        
        fetchMetadata(for: urlString) { metadata in
            DispatchQueue.main.async {
                linkView.metadata = metadata ?? LPLinkMetadata()
            }
        }
        return linkView
    }
    
    func updateNSView(_ nsView: CustomLinkView, context: Context) {
        // Update view if needed
    }
    
    private func fetchMetadata(for urlString: String, completionHandler: @escaping (LPLinkMetadata?) -> Void) {
        guard let url = URL(string: urlString) else {
            log(self, "Invalid URL string")
            completionHandler(nil)
            return
        }

        let metadataProvider = LPMetadataProvider()
        metadataProvider.startFetchingMetadata(for: url) { metadata, error in
            if let error = error {
                log(self, "Error fetching metadata: \(error)")
                completionHandler(nil)
            } else {
                completionHandler(metadata)
            }
        }
    }
}
