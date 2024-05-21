//
//  ClipboardContent.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/18.
//
//

import Foundation
import SwiftData

@Model 
class ClipboardContent {
    var type: String?
    var value: Data?
    
    @Relationship(inverse: \ClipboardHistory.contents) var item: ClipboardHistory?
    
    public init(type: String, value: Data) {
        self.type = type
        self.value = value
    }
}
