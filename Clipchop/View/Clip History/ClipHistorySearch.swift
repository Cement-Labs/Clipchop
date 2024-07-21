//
//  ClipHistorySearch.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/9.
//

import Foundation
import Fuse

class ClipHistorySearch {
    struct SearchResult: Equatable {
        var score: Double?
        var object: Searchable
        var titleMatches: [ClosedRange<Int>]
        
        static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
            return lhs.score == rhs.score &&
                   lhs.object.title == rhs.object.title &&
                   lhs.object.value == rhs.object.value &&
                   lhs.object.app == rhs.object.app &&
                   lhs.titleMatches == rhs.titleMatches
        }
    }
    
    private let fuse = Fuse(threshold: 0.45)
    private let fuzzySearchLimit = 5000
    
    private let prefixMappings: [String: String] = [
        "#app ": "app",
        "#content ": "value",
        "#type ": "title",
        "#应用 ": "app",
        "#内容 ": "value",
        "#类型 ": "title"
    ]
    
    func search(string: String, within: [Searchable]) -> [SearchResult] {
        if string.isEmpty {
            let results = within.map { SearchResult(score: nil, object: $0, titleMatches: []) }
            MetadataCache.shared.setSearchResult(results, for: string)
            return results
        } else {
            if let cachedResults = MetadataCache.shared.getSearchResult(for: string) {
                return cachedResults
            } else {
                let results = fuzzySearch(string: string, within: within)
                MetadataCache.shared.setSearchResult(results, for: string)
                return results
            }
        }
    }
    
    private func fuzzySearch(string: String, within: [Searchable]) -> [SearchResult] {
        let searchType: (String, String?) -> [SearchResult] = { searchString, field in
            let normalizedSearchString = self.normalizeString(searchString)
            let pattern = self.fuse.createPattern(from: normalizedSearchString)
            let searchResults: [SearchResult] = within.compactMap { item in
                let normalizedApp = self.normalizeString(item.app ?? "")
                let normalizedValue = self.normalizeString(item.value)
                let normalizedTitle = self.normalizeString(item.title)
                switch field {
                case "app":
                    return self.fuzzySearch(for: pattern, in: normalizedApp, of: item)
                case "value":
                    return self.fuzzySearch(for: pattern, in: normalizedValue, of: item)
                case "title":
                    return self.fuzzySearch(for: pattern, in: normalizedTitle, of: item)
                default:
                    return self.fuzzySearch(for: pattern, in: normalizedTitle, of: item) ??
                           self.fuzzySearch(for: pattern, in: normalizedValue, of: item) ??
                           self.fuzzySearch(for: pattern, in: normalizedApp, of: item)
                }
            }
            return searchResults.sorted { ($0.score ?? 0) < ($1.score ?? 0) }
        }
        
        let normalizedString = normalizeString(string)
        for (prefix, field) in prefixMappings {
            if normalizedString.hasPrefix(prefix) {
                let searchString = String(normalizedString.dropFirst(prefix.count))
                let results = searchType(searchString, field)
                if results.isEmpty {
                    return simpleSearch(string: searchString, within: within, options: .caseInsensitive)
                }
                return results
            }
        }
        let results = searchType(normalizedString, nil)
        if results.isEmpty {
            return simpleSearch(string: normalizedString, within: within, options: .caseInsensitive)
        }
        return results
    }
    
    private func fuzzySearch(for pattern: Fuse.Pattern?, in searchString: String, of item: Searchable) -> SearchResult? {
        var searchString = searchString
        if searchString.count > fuzzySearchLimit {
            let stopIndex = searchString.index(searchString.startIndex, offsetBy: fuzzySearchLimit)
            searchString = "\(searchString[..<stopIndex])"
        }
        if let fuzzyResult = fuse.search(pattern, in: searchString) {
            return SearchResult(
                score: fuzzyResult.score,
                object: item,
                titleMatches: fuse.search(pattern, in: item.title)?.ranges ?? []
            )
        } else {
            return nil
        }
    }
    
    private func simpleSearch(string: String, within: [Searchable], options: NSString.CompareOptions) -> [SearchResult] {
        return within.compactMap { item in
            simpleSearch(for: string, in: item.title, of: item, options: options) ??
            simpleSearch(for: string, in: item.value, of: item, options: options)
        }
    }
    
    private func simpleSearch(
        for string: String,
        in searchString: String,
        of item: Searchable,
        options: NSString.CompareOptions
    ) -> SearchResult? {
        if searchString.range(
            of: string,
            options: options,
            range: nil,
            locale: nil
        ) != nil {
            var result = SearchResult(
                score: nil,
                object: item,
                titleMatches: []
            )

            let title = item.title
            if let titleRange = title.range(of: string, options: options, range: nil, locale: nil) {
                let lowerBound = title.distance(from: title.startIndex, to: titleRange.lowerBound)
                var upperBound = title.distance(from: title.startIndex, to: titleRange.upperBound)
                if upperBound > lowerBound {
                    upperBound -= 1
                }
                result.titleMatches.append(lowerBound...upperBound)
            }

            return result
        } else {
            return nil
        }
    }
    private func normalizeString(_ string: String) -> String {
        let normalizedString = string.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? string
        return normalizedString
    }
}

protocol Searchable {
    var title: String { get }
    var value: String { get }
    var app: String? { get }
}
