//
//  PreviewContentView.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/21.
//

import SwiftUI
import AppKit
import Defaults

import QuickLook
import QuickLookThumbnailing

import SwiftHEXColors
import LinkPresentation


struct PreviewContentView: View, Equatable {
    
    static func == (lhs: PreviewContentView, rhs: PreviewContentView) -> Bool {
        return lhs.clipboardHistory.id == rhs.clipboardHistory.id
    }
    
    var backgroundColor: Color {
        withAnimation {
            colorScheme == .dark ? .black : .white
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    @State private var thumbnail: NSImage?
    @State private var isThumbnailLoading = false
    
    let clipboardHistory: ClipboardHistory
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Group {
                    if geometry.size.width < 160 {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.clear)
                    } else {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(backgroundColor)
                    }
                }
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
                } else if let html = clipboardHistory.formatter.htmlData {
                    htmlPreviewView(for: html)
                } else {
                    defaultView()
                }
            }
        }
        .onAppear(perform: loadThumbnail)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    // MARK: - View Builders
    
    private func fileThumbnailView(for fileURL: URL) -> some View {
        VStack {
            if isThumbnailLoading {
                loadingView()
            } else if let thumbnail = thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 7.5))
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
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 7.5))
            )
        }
        return AnyView(EmptyView())
    }
    
    private func rtfView(for rtfData: Data) -> some View {
        VStack {
            RTFPreviewPage(rtfData: rtfData, colorScheme: colorScheme)
        }
        .clipShape(RoundedRectangle(cornerRadius: 7.5))
    }
    
    private func textView(for text: String) -> some View {
        if let url = NSURL(string: text), url.scheme != nil {
            return AnyView(
                VStack {
                    WebLinkPreviewPage(urlString: text)
                }
                .clipShape(RoundedRectangle(cornerRadius: 7.5))
            )
        } else if let colorImage = ColorPreviewPage.from(text) {
            return AnyView(
                ZStack {
                    Image(nsImage: colorImage)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                    Text(text)
                        .font(.system(size: 12).monospaced())
                        .minimumScaleFactor(0.8)
                        .lineLimit(10)
                        .fixedSize(horizontal: false, vertical: false)
                        .foregroundColor(foregroundColor(for: colorImage))
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
            )
        } else {
            return AnyView(
                VStack {
                    Text(text)
                        .font(.system(size: 12))
                        .minimumScaleFactor(0.8)
                        .lineLimit(10)
                        .fixedSize(horizontal: false, vertical: false)
                        .foregroundColor(.primary)
                        .padding(.all, 4)
                }
            )
        }
    }
    
    private func urlPreviewView(for url: URL) -> some View {
        VStack {
            WebLinkPreviewPage(urlString: url.absoluteString)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private func htmlPreviewView(for htmlData: Data) -> some View {
        VStack {
            HTMLPreviewPage(htmlData: htmlData, colorScheme: colorScheme)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .background(Color.white)
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
            let maxDimension = 256
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
                        log(self, "Error generating thumbnail: \(error)")
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
    
    // Get cached image
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
    
    // Image preview resolution scaling
    private func resizeImage(image: NSImage) -> NSImage? {
        let maxSize: CGFloat = 256
        let aspectRatio = image.size.width / image.size.height
        let newSize: NSSize
        
        if aspectRatio > 1 {
            newSize = NSSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = NSSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        // Use NSImage's drawing methods with better performance settings
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        defer { newImage.unlockFocus() }
        
        let rect = NSRect(origin: .zero, size: newSize)
        let imageRect = NSRect(origin: .zero, size: image.size)
        image.draw(in: rect, from: imageRect, operation: .copy, fraction: 1.0)
        
        return newImage
    }
    
    // Switch background Color
    private func foregroundColor(for image: NSImage) -> Color {
        guard let averageColor = image.averageColor else {
            return .primary
        }
        return averageColor.isLight ? .secondary : Color(white: 0.9)
    }
}
