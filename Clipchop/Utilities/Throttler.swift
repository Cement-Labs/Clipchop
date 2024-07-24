//
//  Throttler.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/20.
//

import Foundation

class Throttler {
    var minimumDelay: TimeInterval
    
    private var workItem: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun: Date = Date.distantPast
    private let queue: DispatchQueue
    
    init(minimumDelay: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.minimumDelay = minimumDelay
        self.queue = queue
    }
    
    func throttle(_ block: @escaping () -> Void) {
        cancel()
        workItem = DispatchWorkItem { [weak self] in
            self?.previousRun = Date()
            block()
        }
        
        let delay = previousRun.timeIntervalSinceNow > minimumDelay ? 0 : minimumDelay
        queue.asyncAfter(deadline: .now() + Double(delay), execute: workItem)
    }
    
    func cancel() {
        workItem.cancel()
    }
}
