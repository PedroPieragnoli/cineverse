//
//  SeededContinueWatchingStore.swift
//  Cineverse
//

import Foundation

struct SeededContinueWatchingStore: ContinueWatchingStore {
    private let seedItems: [ContinueWatchingItem]

    init(seedItems: [ContinueWatchingItem] = Self.defaultSeedItems()) {
        self.seedItems = seedItems
    }

    func loadItems() async throws -> [ContinueWatchingItem] {
        seedItems
    }

    private static func defaultSeedItems() -> [ContinueWatchingItem] {
        #if DEBUG
        ContinueWatchingItem.mockArray
        #else
        []
        #endif
    }
}
