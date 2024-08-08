//
//  WebLinkPreviewPage.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/21.
//

import SwiftUI
import Defaults
import SFSafeSymbols
import LinkPresentation

class CustomLinkView: LPLinkView {
    override var intrinsicContentSize: CGSize {
        // The most proper size.
        CGSize(width: 210 , height: 210 )
    }
}

struct WebLinkPreview: NSViewRepresentable {
    typealias NSViewType = NSView
    var urlString: String
    
    func makeNSView(context: Context) -> NSView {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL string")
        }
        
        let containerView = NSView()
        
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
        
        // Apply transformations to the link view
        linkView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(linkView)
        
        // Apply constraints
        NSLayoutConstraint.activate([
            linkView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            linkView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])
        
        return containerView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
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

struct WebLinkPreviewPage: View {
    let urlString: String
    @State private var showWebView: Bool = false
    @State private var metadata: LPLinkMetadata?
    @State private var loadedImage: NSImage?
    @State private var iconImage: NSImage?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if geometry.size.width < 160 {
                    if Defaults[.hideTag] {
                        if showWebView {
                            HStack {
                                Image(systemSymbol: .linkCircle)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 7.5))
                                    .frame(maxHeight: 20)
                                Text(metadata?.title ?? "No Title")
                                    .font(.system(size: 7.5))
                                    .lineLimit(5)
                            }
                            .frame(alignment: .center)
                            .padding(.all, 2)
                            .offset(y: Defaults[.hideTag] ? 0 : -10 )
                        } else {
                            HStack {
                                if let image = iconImage {
                                    Image(nsImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 7.5))
                                        .frame(maxHeight: 20)
                                }
                                Text(metadata?.title ?? "No Title")
                                    .font(.system(size: 7.5))
                                    .lineLimit(5)
                            }
                            .frame(alignment: .center)
                            .padding(.all, 2)
                            .offset(y: Defaults[.hideTag] ? 0 : -10 )
                        }
                    } else {
                        if showWebView {
                            HStack {
                                Image(systemSymbol: .linkCircle)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 7.5))
                                    .frame(maxHeight: 20)
                                Text(metadata?.title ?? "No Title")
                                    .font(.system(size: 7.5))
                                    .lineLimit(5)
                            }
                            .frame(alignment: .center)
                            .padding(.all, 2)
                            .offset(y: Defaults[.hideTag] ? 0 : -10 )
                        } else {
                            HStack {
                                if let image = iconImage {
                                    Image(nsImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 7.5))
                                        .frame(maxHeight: 20)
                                }
                                Text(metadata?.title ?? "No Title")
                                    .font(.system(size: 7.5))
                                    .lineLimit(5)
                            }
                            .frame(alignment: .center)
                            .padding(.all, 2)
                            .offset(y: Defaults[.hideTag] ? 0 : -10 )
                        }
                    }
                } else {
                    WebLinkPreview(urlString: urlString)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .onAppear {
                guard let url = URL(string: urlString) else { return }
                MetadataService.shared.fetchMetadata(for: url) { fetchedMetadata in
                    DispatchQueue.main.async {
                        self.metadata = fetchedMetadata
                        self.loadImage(from: fetchedMetadata?.imageProvider)
                        self.loadIcon(from: fetchedMetadata?.iconProvider)
                    }
                }
            }
        }
    }
    
    private func loadImage(from provider: NSItemProvider?) {
        guard let provider = provider else { return }
        
        if provider.canLoadObject(ofClass: NSImage.self) {
            provider.loadObject(ofClass: NSImage.self) { (object, error) in
                if let error = error {
                    print("Error loading image: \(error)")
                } else if let image = object as? NSImage {
                    DispatchQueue.main.async {
                        self.loadedImage = image
                    }
                }
            }
        } else {
            print("Provider cannot load NSImage or NSURL")
            showWebView = true
        }
    }

    private func loadIcon(from provider: NSItemProvider?) {
        guard let provider = provider else { return }
        
        if provider.canLoadObject(ofClass: NSImage.self) {
            provider.loadObject(ofClass: NSImage.self) { (object, error) in
                if let error = error {
                    print("Error loading icon: \(error)")
                } else if let icon = object as? NSImage {
                    DispatchQueue.main.async {
                        self.iconImage = icon
                    }
                }
            }
        } else {
            print("Provider cannot load NSImage or NSURL")
            showWebView = true
        }
    }
}


class MetadataService {
    static let shared = MetadataService()

    private init() {}

    func fetchMetadata(for url: URL, completionHandler: @escaping (LPLinkMetadata?) -> Void) {
        if let cachedMetadata = MetadataCache.shared.getMetadata(for: url.absoluteString) {
            completionHandler(cachedMetadata)
        } else {
            let metadataProvider = LPMetadataProvider()
            metadataProvider.startFetchingMetadata(for: url) { metadata, error in
                if let error = error {
                    print("Error fetching metadata: \(error)")
                    completionHandler(nil)
                } else {
                    if let metadata = metadata {
                        MetadataCache.shared.setMetadata(metadata, for: url.absoluteString)
                    }
                    completionHandler(metadata)
                }
            }
        }
    }
}


