//
//  ClipboardManager.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/6/5.
//

import SwiftUI
import Combine
import Defaults
import SwiftData

class ClipboardManager: ObservableObject {
    
    @Published private(set) var items: [ClipboardHistory] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let container: ModelContainer
    let context: ModelContext
    private var timerCancellable: AnyCancellable?
    
    init() {
        do {
            container = try ModelContainer(for: ClipboardContent.self, ClipboardHistory.self)
            context = ModelContext(container)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }

    }
    
    func deleteOldHistory(preservationPeriod: HistoryPreservationPeriod, preservationTime: Int) {
        guard preservationPeriod != .forever else { return }
        
        let currentDate = Date()
        let cutoffDate: Date
        
        let sortDescriptor = SortDescriptor(\ClipboardHistory.time, order: .reverse)
        let fetchDescriptor = FetchDescriptor<ClipboardHistory>(sortBy: [sortDescriptor])
        
        switch preservationPeriod {
        case .minute:
            cutoffDate = currentDate.addingTimeInterval(-Double(preservationTime * 60))
        case .hour:
            cutoffDate = currentDate.addingTimeInterval(-Double(preservationTime * 60 * 60))
        case .day:
            cutoffDate = currentDate.addingTimeInterval(-Double(preservationTime * 24 * 60 * 60))
        case .month:
            cutoffDate = Calendar.current.date(byAdding: .month, value: -preservationTime, to: currentDate) ?? currentDate
        case .year:
            cutoffDate = Calendar.current.date(byAdding: .year, value: -preservationTime, to: currentDate) ?? currentDate
        default:
            return
        }
        do {
            let items = try context.fetch(fetchDescriptor)
            let itemsToDelete = items.filter { item in
                !item.pinned && item.time! < cutoffDate
            }
            log(self, "\(cutoffDate)")
            for item in itemsToDelete {
                context.delete(item)
            }
            try context.save()
            print("Deleted old history items successfully.")
        } catch {
            print("Failed to fetch ClipboardHistory: \(error)")
            
        }
    }
    
    func startPeriodicCleanup() {
        log(self, "time statr,Cached preservation period: \(Defaults[.historyPreservationPeriod]), Cached preservation time: \(Defaults[.historyPreservationTime])")
        timerCancellable = Timer.publish(every: 100, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.deleteOldHistory(preservationPeriod: Defaults[.historyPreservationPeriod], preservationTime: Int(Defaults[.historyPreservationTime]))
            }
    }
    
    func stopPeriodicCleanup() {
        timerCancellable?.cancel()
        timerCancellable = nil
        log(self, "time stop, \(Defaults[.historyPreservationPeriod]),\(Defaults[.historyPreservationTime])")
    }
    
    func restartPeriodicCleanup() {
        stopPeriodicCleanup()
        startPeriodicCleanup()
        log(self, "\(Defaults[.historyPreservationPeriod]),\(Defaults[.historyPreservationTime])")
    }
    
    private func deleteItem(_ item: ClipboardHistory) {
        if let contents = item.contents {
            for content in contents {
                context.delete(content)
            }
        }
        context.delete(item)
        do {
            try context.save()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
}
