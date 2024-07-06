//
//  MutableCollection+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/26.
//

import Foundation

extension MutableCollection {
    mutating func updateEach(_ update: (inout Element) -> Void) {
        for i in indices {
            update(&self[i])
        }
    }
}
