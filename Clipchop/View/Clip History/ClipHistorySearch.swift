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

    private let fuse = Fuse(threshold: 0.35)
    private let fuzzySearchLimit = 500

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
            return within.map { SearchResult(score: nil, object: $0, titleMatches: []) }
        } else {
            return fuzzySearch(string: string, within: within)
        }
    }

    private func fuzzySearch(string: String, within: [Searchable]) -> [SearchResult] {
        let searchType: (String, String?) -> [SearchResult] = { searchString, field in
            let normalizedSearchString = self.normalizeString(searchString)
            let pattern = self.fuse.createPattern(from: normalizedSearchString)
            let searchResults: [SearchResult] = within.compactMap { item in
                switch field {
                case "app":
                    return self.fuzzySearch(for: pattern, in: self.normalizeString(item.app ?? ""), of: item)
                case "value":
                    return self.fuzzySearch(for: pattern, in: self.normalizeString(item.value), of: item)
                case "title":
                    return self.fuzzySearch(for: pattern, in: self.normalizeString(item.title), of: item)
                default:
                    return self.fuzzySearch(for: pattern, in: self.normalizeString(item.title), of: item) ??
                           self.fuzzySearch(for: pattern, in: self.normalizeString(item.value), of: item) ??
                           self.fuzzySearch(for: pattern, in: self.normalizeString(item.app ?? ""), of: item)
                }
            }
            return searchResults.sorted { ($0.score ?? 0) < ($1.score ?? 0) }
        }

        let normalizedString = normalizeString(string)
        for (prefix, field) in prefixMappings {
            if normalizedString.lowercased().hasPrefix(prefix) {
                let searchString = String(normalizedString.dropFirst(prefix.count))
                return searchType(searchString, field)
            }
        }
        return searchType(normalizedString, nil)
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

    private func normalizeString(_ string: String) -> String {
        return string.applyingTransform(.fullwidthToHalfwidth, reverse: false)?.lowercased() ?? string.lowercased()
    }
}

protocol Searchable {
    var title: String { get }
    var value: String { get }
    var app: String? { get }
}
