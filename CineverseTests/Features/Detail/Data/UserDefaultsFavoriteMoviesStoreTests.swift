//
//  UserDefaultsFavoriteMoviesStoreTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct UserDefaultsFavoriteMoviesStoreTests {

    @Test("contains returns false for an empty store")
    func containsEmpty() {
        let (store, _) = makeStore()

        #expect(store.contains(42) == false)
    }

    @Test("toggle adds a new favorite and returns true")
    func toggleAddsNewFavorite() {
        let (store, _) = makeStore()

        let isFavorite = store.toggle(42)

        #expect(isFavorite)
        #expect(store.contains(42))
    }

    @Test("toggle removes an existing favorite and returns false")
    func toggleRemovesExisting() {
        let (store, _) = makeStore()

        store.toggle(42)
        let isFavorite = store.toggle(42)

        #expect(isFavorite == false)
        #expect(store.contains(42) == false)
    }

    @Test("favorites are independent across IDs")
    func independentIDs() {
        let (store, _) = makeStore()

        store.toggle(1)
        store.toggle(2)
        store.toggle(2)

        #expect(store.contains(1))
        #expect(store.contains(2) == false)
    }

    @Test("favorites persist across new store instances on the same UserDefaults")
    func persistsAcrossInstances() {
        let (store, defaults) = makeStore()
        store.toggle(7)

        let secondStore = UserDefaultsFavoriteMoviesStore(userDefaults: defaults)

        #expect(secondStore.contains(7))
    }

    private func makeStore() -> (
        store: UserDefaultsFavoriteMoviesStore,
        userDefaults: UserDefaults
    ) {
        let suiteName = "test.favorites.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Could not create test UserDefaults suite")
        }
        userDefaults.removePersistentDomain(forName: suiteName)
        return (UserDefaultsFavoriteMoviesStore(userDefaults: userDefaults), userDefaults)
    }
}
