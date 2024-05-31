//
//  Set+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/28.
//

import Foundation

extension Set {
    mutating func updateEach(_ update: (inout Element) -> Void) {
        for i in indices {
            let original = self[i]
            var element = original
            update(&element)
            
            guard original != element else { continue }
            self.remove(original)
            self.insert(element)
        }
    }
}

extension Set where Element == FileType {
    func sorted() -> [FileType] {
        sorted {
            $0.ext < $1.ext
        }
    }
}

extension Set where Element == FileType.Category {
    func sorted() -> [FileType.Category] {
        sorted {
            $0.name < $1.name
        }
    }
}
