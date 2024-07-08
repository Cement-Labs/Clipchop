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
        CGSize(width: 128, height: 128)
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
        
        if let cachedMetadata = MetadataCache.shared.getMetadata(for: urlString) {
            linkView.metadata = cachedMetadata
        } else {
            fetchMetadata(for: urlString) { metadata in
                DispatchQueue.main.async {
                    if let metadata = metadata {
                        MetadataCache.shared.setMetadata(metadata, for: urlString)
                        linkView.metadata = metadata
                    } else {
                        linkView.metadata = LPLinkMetadata()
                    }
                }
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

