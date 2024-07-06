//
//  PreviewContentView.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/21.
//

import SwiftUI
import AppKit

import QuickLook
import QuickLookThumbnailing

import SwiftHEXColors
import LinkPresentation


struct PreviewContentView: View, Equatable {
    
    static func == (lhs: PreviewContentView, rhs: PreviewContentView) -> Bool {
        return lhs.clipboardHistory.id == rhs.clipboardHistory.id
    }
    
    @State private var thumbnail: NSImage?
    @State private var isThumbnailLoading = false
    
    let clipboardHistory: ClipboardHistory
    
    var body: some View {
        VStack(alignment: .leading) {
            if let fileURL = clipboardHistory.formatter.fileURLs.first {
                fileThumbnailView(for: fileURL)
            } else if let image = clipboardHistory.formatter.image {
                imageView(for: image)
            } else if let rtfData = clipboardHistory.formatter.rtfData {
                rtfView(for: rtfData)
            } else if let text = clipboardHistory.formatter.text {
                textView(for: text)
            } else if let url = clipboardHistory.formatter.url {
                urlPreviewView(for: url)
            } else {
                defaultView()
            }
        }
        .onAppear(perform: loadThumbnail)
    }
    
    // MARK: - View Builders
    
    private func fileThumbnailView(for fileURL: URL) -> some View {
        ZStack {
            if isThumbnailLoading {
                loadingView()
            } else if let thumbnail = thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.clear)
        )
    }
    
    private func imageView(for image: NSImage) -> some View {
        if let resizedImage = getCachedOrResizeImage(image: image, for: clipboardHistory.id) {
            return AnyView(
                Image(nsImage: resizedImage)
                    .aspectRatio(contentMode: .fit)
            )
        }
        return AnyView(EmptyView())
    }
    
    private func rtfView(for rtfData: Data) -> some View {
        VStack {
            RTFPreviewPage(rtfData: rtfData)
        }
        .frame(width: 80, height: 80)
        .background(.clear)
    }
    
    private func textView(for text: String) -> some View {
        if let url = NSURL(string: text), url.scheme != nil {
            return AnyView(
                VStack {
                    WebLinkPreviewPage(urlString: text)
                        .scaleEffect(0.625)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//                .offset(y: -14)
                .padding(.all, 5)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            )
        } else if let colorImage = ColorPreviewPage.from(text) {
            return AnyView(
                ZStack {
                    Image(nsImage: colorImage)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .aspectRatio(contentMode: .fit)
                    Text(text)
                        .font(.system(size: 12).monospaced())
                        .minimumScaleFactor(0.8)
                        .lineLimit(10)
                        .fixedSize(horizontal: false, vertical: false)
                        .foregroundColor(.primary)
                }
            )
        } else {
            return AnyView(
                VStack {
                    Text(text)
                        .font(.system(size: 12).monospaced())
                        .minimumScaleFactor(0.8)
                        .lineLimit(10)
                        .fixedSize(horizontal: false, vertical: false)
                        .foregroundColor(.primary)
                }
                .frame(width: 70, height: 70)
            )
        }
    }
    
    private func urlPreviewView(for url: URL) -> some View {
        VStack {
            WebLinkPreviewPage(urlString: url.absoluteString)
                .scaleEffect(0.625)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//        .offset(y: -14)
        .padding(.all, 5)
        
    }
    
    private func defaultView() -> some View {
        Text("Other")
            .font(.system(size: 10).monospaced())
            .foregroundColor(.primary)
    }
    
    private func loadingView() -> some View {
        Text("Loading...")
            .font(.system(size: 10).monospaced())
            .foregroundColor(.white)
    }
    
    // MARK: - Thumbnail Loading
    
    private func loadThumbnail() {
        guard let fileURL = clipboardHistory.formatter.fileURLs.first else { return }
        if let cachedThumbnail = MetadataCache.shared.getThumbnail(for: fileURL) {
            self.thumbnail = cachedThumbnail
        } else {
            isThumbnailLoading = true
            DispatchQueue.global().async {
                self.generateAndSetThumbnail(for: fileURL)
            }
        }
    }
    
    private func generateAndSetThumbnail(for fileURL: URL) {
        DispatchQueue.global(qos: .utility).async {
            let maxDimension = 80
            let size = CGSize(width: maxDimension, height: maxDimension)
            let scale = NSScreen.main!.backingScaleFactor
            let request = QLThumbnailGenerator.Request(
                fileAt: fileURL,
                size: size,
                scale: scale,
                representationTypes: .all
            )
            
            QLThumbnailGenerator.shared.generateRepresentations(for: request) { thumbnail, _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        log(/*self,*/ "Error generating thumbnail: \(error)")
                    } else if let cgImage = thumbnail?.cgImage {
                        let nsImage = NSImage(cgImage: cgImage, size: NSSize())
                        self.thumbnail = nsImage
                        MetadataCache.shared.setThumbnail(nsImage, for: fileURL)
                    }
                    self.isThumbnailLoading = false
                }
            }
        }
    }
    
    // MARK: - Resize Image
    
    private func getCachedOrResizeImage(image: NSImage, for identifier: UUID?) -> NSImage? {
        guard let identifier = identifier else { return nil }
        if let cachedImage = MetadataCache.shared.getResizedImage(for: identifier) {
            return cachedImage
        } else {
            let resizedImage = resizeImage(image: image)
            if let resizedImage = resizedImage {
                MetadataCache.shared.setResizedImage(resizedImage, for: identifier)
            }
            return resizedImage
        }
    }
    
    private func resizeImage(image: NSImage) -> NSImage? {
        let maxSize: CGFloat = 80
        let newSize: NSSize
        
        if image.size.width > image.size.height {
            let ratio = maxSize / image.size.width
            newSize = NSSize(width: maxSize, height: image.size.height * ratio)
        } else {
            let ratio = maxSize / image.size.height
            newSize = NSSize(width: image.size.width * ratio, height: maxSize)
        }
        
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: image.size), operation: .copy, fraction: 1)
        newImage.unlockFocus()
        
        return newImage
    }
}
