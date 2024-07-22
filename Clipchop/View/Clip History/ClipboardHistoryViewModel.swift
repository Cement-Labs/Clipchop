//
//  ClipboardHistoryViewModel.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/22.
//

import SwiftUI
import Combine
import CoreData

class ClipboardHistoryViewModel: ObservableObject {
    @Published var items: [ClipboardHistory] = []
    private var cancellables = Set<AnyCancellable>()
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadItems()
    }

    private func loadItems() {
        Deferred {
            Future<[ClipboardHistory], Error> { promise in
                self.fetchItemsFromCoreData { result in
                    switch result {
                    case .success(let items):
                        promise(.success(items))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Error loading items: \(error)")
            case .finished:
                break
            }
        }, receiveValue: { [weak self] loadedItems in
            self?.items = loadedItems
        })
        .store(in: &cancellables)
    }

    private func fetchItemsFromCoreData(completion: @escaping (Result<[ClipboardHistory], Error>) -> Void) {
        context.perform {
            let fetchRequest: NSFetchRequest<ClipboardHistory> = ClipboardHistory.fetchRequest()
            do {
                let items = try self.context.fetch(fetchRequest)
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
