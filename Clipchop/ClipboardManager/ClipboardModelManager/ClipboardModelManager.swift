//
//  ClipboardManager.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import SwiftUI
import Combine
import Defaults

class ClipboardModelManager: ObservableObject {
    
    @Published private(set) var items: [ClipboardHistory] = []
    
    private var provider = ClipboardDataProvider.shared
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func deleteOldHistory(preservationPeriod: HistoryPreservationPeriod, preservationTime: Int) {
        guard preservationPeriod != .forever else { return }
        
        let currentDate = Date()
        let cutoffDate: Date
        let fetchDescriptor = NSFetchRequest<ClipboardHistory>()
        
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
                !item.pin && item.time! < cutoffDate
            }
            log(self, "\(cutoffDate)")
            for item in itemsToDelete {
                try deleteItem(item)
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
    
    private func deleteItem(_ item: ClipboardHistory) throws {
        let context = provider.viewContext
        let existingItem = try context.existingObject(with: item.objectID)
        context.delete(existingItem)
        Task(priority: .background) {
            try await context.perform {
                try context.save()
            }
        }
    }
}
