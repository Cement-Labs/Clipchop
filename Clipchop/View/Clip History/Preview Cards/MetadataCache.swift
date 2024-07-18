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
    private var previewCache: [String: String] = [:]
    private var searchResultCache: [String: [ClipHistorySearch.SearchResult]] = [:]

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
    
    func getPreview(for cacheKey: String) -> String? {
        return previewCache[cacheKey]
    }

    func setPreview(_ preview: String, for cacheKey: String) {
        previewCache[cacheKey] = preview
    }
    
    func getSearchResult(for query: String) -> [ClipHistorySearch.SearchResult]? {
        return searchResultCache[query]
    }

    func setSearchResult(_ results: [ClipHistorySearch.SearchResult], for query: String) {
        searchResultCache[query] = results
    }
}
