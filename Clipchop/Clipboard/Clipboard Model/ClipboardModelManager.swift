//
//  ClipboardManager.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/5.
//

import SwiftUI
import Combine
import CoreData
import Defaults

class ClipboardModelManager: ObservableObject {
    @Published private(set) var items: [ClipboardHistory] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private var timerCancellable: AnyCancellable?
    private var provider = ClipboardDataProvider.shared
    
    init() {
        container = NSPersistentContainer(name: "ClipboardModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        context = container.viewContext
        context.automaticallyMergesChangesFromParent = true // Enable automatic merging of changes
    }
    
    func deleteOldHistory(preservationPeriod: HistoryPreservationPeriod, preservationTime: Int) {
        guard preservationPeriod != .forever else { return }
        
        let currentDate = Date()
        let cutoffDate: Date
        
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
        
        let fetchRequest = NSFetchRequest<ClipboardHistory>(entityName: "ClipboardHistory")
        fetchRequest.predicate = NSPredicate(format: "pin == NO AND time < %@", cutoffDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ClipboardHistory.time, ascending: false)]
        
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                try deleteItem(item)
            }
            try context.save()
            log(self, "Deleted old history items successfully.")
        } catch {
            log(self, "Failed to fetch ClipboardHistory: \(error)")
        }
    }
    
    func startPeriodicCleanup() {
        log(self, "time start, Cached preservation period: \(Defaults[.historyPreservationPeriod]), Cached preservation time: \(Defaults[.historyPreservationTime])")
        timerCancellable = Timer.publish(every: 100, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.deleteOldHistory(
                    preservationPeriod: Defaults[.historyPreservationPeriod],
                    preservationTime: Int(Defaults[.historyPreservationTime])
                )
            }
    }
    
    func stopPeriodicCleanup() {
        timerCancellable?.cancel()
        timerCancellable = nil
        log(self, "time stop, \(Defaults[.historyPreservationPeriod]), \(Defaults[.historyPreservationTime])")
    }
    
    func restartPeriodicCleanup() {
        stopPeriodicCleanup()
        startPeriodicCleanup()
        log(self, "\(Defaults[.historyPreservationPeriod]), \(Defaults[.historyPreservationTime])")
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
