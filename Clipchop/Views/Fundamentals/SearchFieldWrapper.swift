//
//  SearchFieldWrapper.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/21.
//

import SwiftUI
import AppKit

struct SearchFieldWrapper: View {
    @Binding var searchText: String
    var placeholder: String
    var onSearch: (String) -> Void
    
    private let searchThrottler = Throttler(minimumDelay: 0.7)
    
    var body: some View {
        TextField(placeholder, text: Binding(
            get: {
                searchText
            },
            set: { newValue in
                searchThrottler.throttle {
                    searchText = newValue
                    onSearch(newValue)
                }
            }
        ))
        .textFieldStyle(PlainTextFieldStyle())
    }
}
