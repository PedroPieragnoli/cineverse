//
//  ContinueWatchingStore.swift
//  Cineverse
//

import Foundation

protocol ContinueWatchingStore: Sendable {
    func loadItems() async throws -> [ContinueWatchingItem]
}
