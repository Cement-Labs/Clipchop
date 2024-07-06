//
//  MetadataCache.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/6/6.
//

import LinkPresentation
import QuickLook

class MetadataCache {
    static let shared = MetadataCache()
    private var metadataCache: [String: LPLinkMetadata] = [:]
    private var thumbnailCache: [URL: NSImage] = [:]
    private var resizedImageCache: [UUID: NSImage] = [:]

    private init() {}

    func getMetadata(for urlString: String) -> LPLinkMetadata? {
        return metadataCache[urlString]
    }

    func setMetadata(_ metadata: LPLinkMetadata, for urlString: String) {
        metadataCache[urlString] = metadata
    }

    func getThumbnail(for url: URL) -> NSImage? {
        return thumbnailCache[url]
    }

    func setThumbnail(_ thumbnail: NSImage, for url: URL) {
        thumbnailCache[url] = thumbnail
    }

    func getResizedImage(for identifier: UUID) -> NSImage? {
        return resizedImageCache[identifier]
    }

    func setResizedImage(_ image: NSImage, for identifier: UUID) {
        resizedImageCache[identifier] = image
    }
}
