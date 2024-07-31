//
//  MetadataCache.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/6/6.
//

import LinkPresentation
import QuickLook

import Foundation
import AppKit

class MetadataCache {
    static let shared = MetadataCache()
    
    private let fileManager = FileManager.default
    private let metadataCacheURL: URL
    private let thumbnailCacheURL: URL
    private let resizedImageCacheURL: URL
    private let previewCacheURL: URL
    private let searchResultCacheURL: URL
    
    private var metadataDict = [NSString: NSData]()
    private var thumbnailDict = [NSString: NSData]()
    private var resizedImageDict = [NSString: NSData]()
    private var previewDict = [NSString: NSString]()
    private var searchResultDict = [NSString: NSData]()
    
    private let metadataNSCache = NSCache<NSString, NSData>()
    private let thumbnailNSCache = NSCache<NSString, NSData>()
    private let resizedImageNSCache = NSCache<NSString, NSData>()
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
        setupCacheEviction()
    }
    
    private func loadCaches() {
        loadCache(from: metadataCacheURL, to: &metadataDict, using: metadataNSCache)
        loadCache(from: thumbnailCacheURL, to: &thumbnailDict, using: thumbnailNSCache)
        loadCache(from: resizedImageCacheURL, to: &resizedImageDict, using: resizedImageNSCache)
        loadCache(from: previewCacheURL, to: &previewDict, using: previewNSCache)
        loadCache(from: searchResultCacheURL, to: &searchResultDict, using: searchResultNSCache)
    }
    
    private func loadCache<T: NSCoding>(from url: URL, to dict: inout [NSString: T], using cache: NSCache<NSString, T>) {
        if let data = try? Data(contentsOf: url),
           let loadedDict = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: data) as? [NSString: T] {
            dict = loadedDict
            loadedDict.forEach { key, value in
                cache.setObject(value, forKey: key)
            }
        }
    }
    
    private func saveCache<T: NSCoding>(from dict: [NSString: T], to url: URL) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: true) {
            try? data.write(to: url)
        }
    }
    
    private func setupCacheEviction() {
        metadataNSCache.evictsObjectsWithDiscardedContent = true
        thumbnailNSCache.evictsObjectsWithDiscardedContent = true
        resizedImageNSCache.evictsObjectsWithDiscardedContent = true
        previewNSCache.evictsObjectsWithDiscardedContent = true
        searchResultNSCache.evictsObjectsWithDiscardedContent = true
        
        metadataNSCache.totalCostLimit = 50 * 1024 * 1024
        thumbnailNSCache.totalCostLimit = 50 * 1024 * 1024
        resizedImageNSCache.totalCostLimit = 50 * 1024 * 1024
        previewNSCache.totalCostLimit = 50 * 1024 * 1024
        searchResultNSCache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func clearAllCaches() {
        
        metadataNSCache.removeAllObjects()
        thumbnailNSCache.removeAllObjects()
        resizedImageNSCache.removeAllObjects()
        previewNSCache.removeAllObjects()
        searchResultNSCache.removeAllObjects()
        
        clearCacheFile(at: metadataCacheURL)
        clearCacheFile(at: thumbnailCacheURL)
        clearCacheFile(at: resizedImageCacheURL)
        clearCacheFile(at: previewCacheURL)
        clearCacheFile(at: searchResultCacheURL)
    }
    
    private func clearCacheFile(at url: URL) {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("Failed to delete cache file at \(url): \(error)")
        }
    }
    
    func getMetadata(for urlString: String) -> LPLinkMetadata? {
        if let cachedData = metadataNSCache.object(forKey: urlString as NSString) as Data? {
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: cachedData)
        }
        return nil
    }

    func setMetadata(_ metadata: LPLinkMetadata, for urlString: String) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: true) {
            let key = urlString as NSString
            metadataNSCache.setObject(data as NSData, forKey: key)
            metadataDict[key] = data as NSData
            saveCache(from: metadataDict, to: metadataCacheURL)
        }
    }

    func getThumbnail(for url: URL) -> NSImage? {
        let urlKey = url.absoluteString as NSString
        if let cachedData = thumbnailNSCache.object(forKey: urlKey) as Data? {
            return NSImage(data: cachedData)
        }
        return nil
    }

    func setThumbnail(_ thumbnail: NSImage, for url: URL) {
        let urlKey = url.absoluteString as NSString
        if let data = thumbnail.tiffRepresentation {
            thumbnailNSCache.setObject(data as NSData, forKey: urlKey)
            thumbnailDict[urlKey] = data as NSData
            saveCache(from: thumbnailDict, to: thumbnailCacheURL)
        }
    }

    func getResizedImage(for identifier: UUID) -> NSImage? {
        let uuidKey = identifier.uuidString as NSString
        if let cachedData = resizedImageNSCache.object(forKey: uuidKey) as Data? {
            return NSImage(data: cachedData)
        }
        return nil
    }

    func setResizedImage(_ image: NSImage, for identifier: UUID) {
        let uuidKey = identifier.uuidString as NSString
        if let data = image.tiffRepresentation {
            resizedImageNSCache.setObject(data as NSData, forKey: uuidKey)
            resizedImageDict[uuidKey] = data as NSData
            saveCache(from: resizedImageDict, to: resizedImageCacheURL)
        }
    }
    
    func getPreview(for cacheKey: String) -> String? {
        if let cachedData = previewNSCache.object(forKey: cacheKey as NSString) {
            return cachedData as String
        }
        return nil
    }

    func setPreview(_ preview: String, for cacheKey: String) {
        let key = cacheKey as NSString
        previewNSCache.setObject(preview as NSString, forKey: key)
        previewDict[key] = preview as NSString
        saveCache(from: previewDict, to: previewCacheURL)
    }

    func getSearchResult(for query: String) -> [ClipHistorySearch.SearchResult]? {
        if let cachedData = searchResultNSCache.object(forKey: query as NSString) as Data? {
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: cachedData) as? [ClipHistorySearch.SearchResult]
        }
        return nil
    }

    func setSearchResult(_ results: [ClipHistorySearch.SearchResult], for query: String) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: results, requiringSecureCoding: true) {
            let key = query as NSString
            searchResultNSCache.setObject(data as NSData, forKey: key)
            searchResultDict[key] = data as NSData
            saveCache(from: searchResultDict, to: searchResultCacheURL)
        }
    }
}
