//
//  ContinueWatchingStore.swift
//  Cineverse
//

import Foundation

protocol ContinueWatchingStore {
    func loadItems() async throws -> [ContinueWatchingItem]
}
