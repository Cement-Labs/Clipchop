//
//  ClipHistorySearch.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/9.
//

import Foundation
import Fuse

class Search {
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

    private let fuse = Fuse(threshold: 0.9)
    private let fuzzySearchLimit = 5_000

    func search(string: String, within: [Searchable]) -> [SearchResult] {
        if string.isEmpty {
            return within.map { SearchResult(score: nil, object: $0, titleMatches: []) }
        } else {
            return fuzzySearch(string: string, within: within)
        }
    }

    private func fuzzySearch(string: String, within: [Searchable]) -> [SearchResult] {
        let pattern = fuse.createPattern(from: string)
        let searchResults: [SearchResult] = within.compactMap { item in
            fuzzySearch(for: pattern, in: item.title, of: item) ??
            fuzzySearch(for: pattern, in: item.value, of: item) ??
            fuzzySearch(for: pattern, in: item.app ?? "", of: item)
        }
        let sortedResults = searchResults.sorted { ($0.score ?? 0) < ($1.score ?? 0) }
        return sortedResults
    }

    private func fuzzySearch(for pattern: Fuse.Pattern?, in searchString: String, of item: Searchable) -> SearchResult? {
        var searchString = searchString
        if searchString.count > fuzzySearchLimit {
            let stopIndex = searchString.index(searchString.startIndex, offsetBy: fuzzySearchLimit)
            searchString = "\(searchString[...stopIndex])"
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
}

protocol Searchable {
    var title: String { get }
    var value: String { get }
    var app: String? { get }
}

extension ClipboardHistory: Searchable {
    var title: String {
        Formatter(contents: Array(self.contents as? Set<ClipboardContent> ?? [])).title ?? ""
    }
    
    var value: String {
        Formatter(contents: Array(self.contents as? Set<ClipboardContent> ?? [])).contentPreview
    }
    
    var apps: String? {
        self.app
    }
}
