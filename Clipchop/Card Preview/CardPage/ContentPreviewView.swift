//
//  ContentPreviewView.swift
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

struct PreviewContentView : View {
    
    @State private var thumbnail: NSImage?
    @State private var isThumbnailLoading = false
    
    let clipboardHistory: ClipboardHistory
    
    var body: some View {
        VStack(alignment: .leading) {
            if let fileURL = clipboardHistory.formatter.fileURLs.first {
                fileThumbnailView(for: fileURL)
            } else if let image = clipboardHistory.formatter.image {
                if let resizedImage = resizeImage(image: image) {
                    Image(nsImage: resizedImage)
                        .aspectRatio(contentMode: .fit)
                }
            } else if let rtfData = clipboardHistory.formatter.rtfData {
                VStack{
                    RTFView(rtfData: rtfData)
                }
                .frame(width: 70, height: 70)
            } else if let text = clipboardHistory.formatter.text {
                VStack{
                    Text(text)
                        .font(.system(size: 12).monospaced())
                        .minimumScaleFactor(0.8)
                        .lineLimit(10)
                        .fixedSize(horizontal: false, vertical: false)
                        .foregroundColor(.primary)
                }
                .frame(width: 70, height: 70)
            } else if let html = clipboardHistory.formatter.htmlString {
                VStack {
//                    CustomLinkViewRepresentable(urlString: html)
//                        .scaleEffect(0.625)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else if let text = clipboardHistory.formatter.text {
                   if let colorImage = ColorView.from(text) {
                    ZStack{
                        Image(nsImage: colorImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Text(text)
                            .font(.system(size: 12).monospaced())
                            .minimumScaleFactor(0.8)
                            .lineLimit(10)
                            .fixedSize(horizontal: false, vertical: false)
                            .foregroundColor(.primary)
                    }
                    .frame(width: 80, height: 80)
                } else {
                    VStack{
                        Text(text)
                            .font(.system(size: 12).monospaced())
                            .minimumScaleFactor(0.8)
                            .lineLimit(10)
                            .fixedSize(horizontal: false, vertical: false)
                            .foregroundColor(.primary)
                    }
                    .frame(width: 70, height: 70)
                }
            } else {
                Text("Other")
                    .font(.system(size: 10).monospaced())
                    .foregroundColor(.primary)
            }
        }
        .onAppear(perform: loadThumbnail)
    }
    
    // MARK: - QuickLookViewLoader
    
    private func fileThumbnailView(for fileURL: URL) -> some View {
        ZStack {
            if isThumbnailLoading {
                Text("Loding...")
                    .font(.system(size: 10).monospaced())
                    .foregroundColor(.white)
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
    
    private func loadThumbnail() {
        if let fileURL = clipboardHistory.formatter.fileURLs.first {
            isThumbnailLoading = true
            DispatchQueue.global().async {
                self.generateAndSetThumbnail(for: fileURL)
            }
        }
    }
    
    private func generateAndSetThumbnail(for fileURL: URL) {
        DispatchQueue.global(qos: .utility).async {
            let maxDimension = 128.0
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
                        print("Error generating thumbnail: \(error)")
                    } else if let cgImage = thumbnail?.cgImage {
                        self.thumbnail = NSImage(cgImage: cgImage, size: NSSize())
                    }
                    self.isThumbnailLoading = false
                }
            }
        }
    }
    
    func resizeImage(image: NSImage) -> NSImage? {
        let maxSize: CGFloat = 80

        var newWidth: CGFloat
        var newHeight: CGFloat

        if image.size.width > image.size.height {
            let ratio = maxSize / image.size.width
            newWidth = maxSize
            newHeight = image.size.height * ratio
        } else {
            let ratio = maxSize / image.size.height
            newWidth = image.size.width * ratio
            newHeight = maxSize
        }
        let newSize = NSSize(width: newWidth, height: newHeight)
        let newImage = NSImage(size: newSize)

        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: image.size), operation: .copy, fraction: 1)
        newImage.unlockFocus()

        return newImage
    }
}
