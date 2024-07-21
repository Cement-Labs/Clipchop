//
//  MetadataCache.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/6/6.
//

import LinkPresentation
import QuickLook
//
//class MetadataCache {
//    static let shared = MetadataCache()
//    private var metadataCache: [String: LPLinkMetadata] = [:]
//    private var thumbnailCache: [URL: NSImage] = [:]
//    private var resizedImageCache: [UUID: NSImage] = [:]
//    private var previewCache: [String: String] = [:]
//    private var searchResultCache: [String: [ClipHistorySearch.SearchResult]] = [:]
//
//    private init() {}
//
//    func getMetadata(for urlString: String) -> LPLinkMetadata? {
//        return metadataCache[urlString]
//    }
//
//    func setMetadata(_ metadata: LPLinkMetadata, for urlString: String) {
//        metadataCache[urlString] = metadata
//    }
//
//    func getThumbnail(for url: URL) -> NSImage? {
//        return thumbnailCache[url]
//    }
//
//    func setThumbnail(_ thumbnail: NSImage, for url: URL) {
//        thumbnailCache[url] = thumbnail
//    }
//
//    func getResizedImage(for identifier: UUID) -> NSImage? {
//        return resizedImageCache[identifier]
//    }
//
//    func setResizedImage(_ image: NSImage, for identifier: UUID) {
//        resizedImageCache[identifier] = image
//    }
//    
//    func getPreview(for cacheKey: String) -> String? {
//        return previewCache[cacheKey]
//    }
//
//    func setPreview(_ preview: String, for cacheKey: String) {
//        previewCache[cacheKey] = preview
//    }
//    
//    func getSearchResult(for query: String) -> [ClipHistorySearch.SearchResult]? {
//        return searchResultCache[query]
//    }
//
//    func setSearchResult(_ results: [ClipHistorySearch.SearchResult], for query: String) {
//        searchResultCache[query] = results
//    }
//}
//class MetadataCache {
//    static let shared = MetadataCache()
//    
//    private let metadataCache = NSCache<NSString, LPLinkMetadata>()
//    private let thumbnailCache = NSCache<NSURL, NSImage>()
//    private let resizedImageCache = NSCache<NSUUID, NSImage>()
//    private let previewCache = NSCache<NSString, NSString>()
//    private let searchResultCache = NSCache<NSString, NSArray>()
//
//    private init() {}
//
//    func getMetadata(for urlString: String) -> LPLinkMetadata? {
//        return metadataCache.object(forKey: urlString as NSString)
//    }
//
//    func setMetadata(_ metadata: LPLinkMetadata, for urlString: String) {
//        metadataCache.setObject(metadata, forKey: urlString as NSString)
//    }
//
//    func getThumbnail(for url: URL) -> NSImage? {
//        return thumbnailCache.object(forKey: url as NSURL)
//    }
//
//    func setThumbnail(_ thumbnail: NSImage, for url: URL) {
//        thumbnailCache.setObject(thumbnail, forKey: url as NSURL)
//    }
//
//    func getResizedImage(for identifier: UUID) -> NSImage? {
//        return resizedImageCache.object(forKey: identifier as NSUUID)
//    }
//
//    func setResizedImage(_ image: NSImage, for identifier: UUID) {
//        resizedImageCache.setObject(image, forKey: identifier as NSUUID)
//    }
//    
//    func getPreview(for cacheKey: String) -> String? {
//        return previewCache.object(forKey: cacheKey as NSString) as String?
//    }
//
//    func setPreview(_ preview: String, for cacheKey: String) {
//        previewCache.setObject(preview as NSString, forKey: cacheKey as NSString)
//    }
//    
//    func getSearchResult(for query: String) -> [ClipHistorySearch.SearchResult]? {
//        return searchResultCache.object(forKey: query as NSString) as? [ClipHistorySearch.SearchResult]
//    }
//
//    func setSearchResult(_ results: [ClipHistorySearch.SearchResult], for query: String) {
//        searchResultCache.setObject(results as NSArray, forKey: query as NSString)
//    }
//}


class MetadataCache {
    static let shared = MetadataCache()
    
    private let fileManager = FileManager.default
    private let metadataCacheURL: URL
    private let thumbnailCacheURL: URL
    private let resizedImageCacheURL: URL
    private let previewCacheURL: URL
    private let searchResultCacheURL: URL
    
    private var metadataCache: [String: Data] = [:]
    private var thumbnailCache: [URL: Data] = [:]
    private var resizedImageCache: [UUID: Data] = [:]
    private var previewCache: [String: String] = [:]
    private var searchResultCache: [String: Data] = [:]
    
    private let metadataNSCache = NSCache<NSString, NSData>()
    private let thumbnailNSCache = NSCache<NSURL, NSData>()
    private let resizedImageNSCache = NSCache<NSUUID, NSData>()
    private let previewNSCache = NSCache<NSString, NSString>()
    private let searchResultNSCache = NSCache<NSString, NSData>()
    
    private init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        metadataCacheURL = cachesDirectory.appendingPathComponent("metadataCache")
        thumbnailCacheURL = cachesDirectory.appendingPathComponent("thumbnailCache")
        resizedImageCacheURL = cachesDirectory.appendingPathComponent("resizedImageCache")
        previewCacheURL = cachesDirectory.appendingPathComponent("previewCache")
        searchResultCacheURL = cachesDirectory.appendingPathComponent("searchResultCache")
        
        loadCaches()
    }
    
    private func loadCaches() {
        if let metadataData = try? Data(contentsOf: metadataCacheURL),
           let metadataDict = try? JSONDecoder().decode([String: Data].self, from: metadataData) {
            metadataCache = metadataDict
            metadataDict.forEach { key, value in
                metadataNSCache.setObject(value as NSData, forKey: key as NSString)
            }
        }
        
        if let thumbnailData = try? Data(contentsOf: thumbnailCacheURL),
           let thumbnailDict = try? JSONDecoder().decode([URL: Data].self, from: thumbnailData) {
            thumbnailCache = thumbnailDict
            thumbnailDict.forEach { key, value in
                thumbnailNSCache.setObject(value as NSData, forKey: key as NSURL)
            }
        }
        
        if let resizedImageData = try? Data(contentsOf: resizedImageCacheURL),
           let resizedImageDict = try? JSONDecoder().decode([UUID: Data].self, from: resizedImageData) {
            resizedImageCache = resizedImageDict
            resizedImageDict.forEach { key, value in
                resizedImageNSCache.setObject(value as NSData, forKey: key as NSUUID)
            }
        }
        
        if let previewData = try? Data(contentsOf: previewCacheURL),
           let previewDict = try? JSONDecoder().decode([String: String].self, from: previewData) {
            previewCache = previewDict
            previewDict.forEach { key, value in
                previewNSCache.setObject(value as NSString, forKey: key as NSString)
            }
        }
        
        if let searchResultData = try? Data(contentsOf: searchResultCacheURL),
           let searchResultDict = try? JSONDecoder().decode([String: Data].self, from: searchResultData) {
            searchResultCache = searchResultDict
            searchResultDict.forEach { key, value in
                searchResultNSCache.setObject(value as NSData, forKey: key as NSString)
            }
        }
    }
    
    private func saveCache<T: Encodable>(_ cache: T, to url: URL) {
        if let data = try? JSONEncoder().encode(cache) {
            try? data.write(to: url)
        }
    }
    
    func getMetadata(for urlString: String) -> LPLinkMetadata? {
        if let cachedData = metadataNSCache.object(forKey: urlString as NSString) as Data? {
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: cachedData)
        }
        
        if let data = metadataCache[urlString],
           let metadata = try? NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: data) {
            metadataNSCache.setObject(data as NSData, forKey: urlString as NSString)
            return metadata
        }
        return nil
    }

    func setMetadata(_ metadata: LPLinkMetadata, for urlString: String) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: true) {
            metadataCache[urlString] = data
            metadataNSCache.setObject(data as NSData, forKey: urlString as NSString)
            saveCache(metadataCache, to: metadataCacheURL)
        }
    }

    func getThumbnail(for url: URL) -> NSImage? {
        if let cachedData = thumbnailNSCache.object(forKey: url as NSURL) as Data? {
            return NSImage(data: cachedData)
        }
        
        if let data = thumbnailCache[url],
           let image = NSImage(data: data) {
            thumbnailNSCache.setObject(data as NSData, forKey: url as NSURL)
            return image
        }
        return nil
    }

    func setThumbnail(_ thumbnail: NSImage, for url: URL) {
        if let data = thumbnail.tiffRepresentation {
            thumbnailCache[url] = data
            thumbnailNSCache.setObject(data as NSData, forKey: url as NSURL)
            saveCache(thumbnailCache, to: thumbnailCacheURL)
        }
    }

    func getResizedImage(for identifier: UUID) -> NSImage? {
        if let cachedData = resizedImageNSCache.object(forKey: identifier as NSUUID) as Data? {
            return NSImage(data: cachedData)
        }
        
        if let data = resizedImageCache[identifier],
           let image = NSImage(data: data) {
            resizedImageNSCache.setObject(data as NSData, forKey: identifier as NSUUID)
            return image
        }
        return nil
    }

    func setResizedImage(_ image: NSImage, for identifier: UUID) {
        if let data = image.tiffRepresentation {
            resizedImageCache[identifier] = data
            resizedImageNSCache.setObject(data as NSData, forKey: identifier as NSUUID)
            saveCache(resizedImageCache, to: resizedImageCacheURL)
        }
    }
    
    func getPreview(for cacheKey: String) -> String? {
        if let cachedData = previewNSCache.object(forKey: cacheKey as NSString) as String? {
            return cachedData
        }
        
        if let preview = previewCache[cacheKey] {
            previewNSCache.setObject(preview as NSString, forKey: cacheKey as NSString)
            return preview
        }
        return nil
    }

    func setPreview(_ preview: String, for cacheKey: String) {
        previewCache[cacheKey] = preview
        previewNSCache.setObject(preview as NSString, forKey: cacheKey as NSString)
        saveCache(previewCache, to: previewCacheURL)
    }
    
    func getSearchResult(for query: String) -> [ClipHistorySearch.SearchResult]? {
        if let cachedData = searchResultNSCache.object(forKey: query as NSString) as Data? {
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: cachedData) as? [ClipHistorySearch.SearchResult]
        }
        
        if let data = searchResultCache[query],
           let results = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [ClipHistorySearch.SearchResult] {
            searchResultNSCache.setObject(data as NSData, forKey: query as NSString)
            return results
        }
        return nil
    }

    func setSearchResult(_ results: [ClipHistorySearch.SearchResult], for query: String) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: results, requiringSecureCoding: true) {
            searchResultCache[query] = data
            searchResultNSCache.setObject(data as NSData, forKey: query as NSString)
            saveCache(searchResultCache, to: searchResultCacheURL)
        }
    }
}

