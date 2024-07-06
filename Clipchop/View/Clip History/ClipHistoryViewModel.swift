//
//  ClipHistoryViewModel.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/6/7.
//

import Foundation

class ClipHistoryViewModel: ObservableObject {

    @Published var viewState: ViewState = .collapsed

    enum ViewState {
        case expanded
        case collapsed
    }
}
