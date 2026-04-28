//
//  SeededContinueWatchingStore.swift
//  Cineverse
//

import Foundation

struct SeededContinueWatchingStore: ContinueWatchingStore {
    private let seedItems: [ContinueWatchingItem]

    init(seedItems: [ContinueWatchingItem] = []) {
        self.seedItems = seedItems
    }

    func loadItems() async throws -> [ContinueWatchingItem] {
        seedItems
    }
}
