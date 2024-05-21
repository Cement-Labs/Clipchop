//
//  WebLinkView.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/21.
//

import SwiftUI
import LinkPresentation

class CustomLinkView: LPLinkView {
    override var intrinsicContentSize: CGSize {
//This size is selected and scaling is applied for display because it enables the content to be visible.
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
            print("Invalid URL string")
            completionHandler(nil)
            return
        }

        let metadataProvider = LPMetadataProvider()
        metadataProvider.startFetchingMetadata(for: url) { metadata, error in
            if let error = error {
                print("Error fetching metadata: \(error)")
                completionHandler(nil)
            } else {
                completionHandler(metadata)
            }
        }
    }
}
