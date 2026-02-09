//
//  SeededContinueWatchingStoreTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct SeededContinueWatchingStoreTests {
    @Test("Store returns provided seed items")
    func returnsProvidedSeedItems() async throws {
        let first = ContinueWatchingItem(
            movie: makeMovie(id: 501),
            progress: 0.25,
            remainingSeconds: 1_800
        )
        let second = ContinueWatchingItem(
            movie: makeMovie(id: 502),
            progress: 0.80,
            remainingSeconds: 420
        )

        let store = SeededContinueWatchingStore(seedItems: [first, second])
        let loaded = try await store.loadItems()

        #expect(loaded.count == 2)
        #expect(loaded[0].movie.id == 501)
        #expect(loaded[0].progress == 0.25)
        #expect(loaded[0].remainingSeconds == 1_800)
        #expect(loaded[1].movie.id == 502)
        #expect(loaded[1].progress == 0.80)
        #expect(loaded[1].remainingSeconds == 420)
    }

    @Test("Default store returns a valid non-throwing array")
    func defaultStoreReturnsArray() async throws {
        let store = SeededContinueWatchingStore()
        let loaded = try await store.loadItems()

        #if DEBUG
        #expect(!loaded.isEmpty)
        #else
        #expect(loaded.isEmpty)
        #endif
    }
}

private func makeMovie(id: Int) -> Movie {
    Movie(
        id: id,
        adult: false,
        backdropPath: "/backdrop-\(id).jpg",
        genreIds: [28],
        originalLanguage: "en",
        originalTitle: "Original \(id)",
        overview: "Overview \(id)",
        popularity: 33.0,
        posterPath: "/poster-\(id).jpg",
        releaseDate: "2025-01-01",
        title: "Movie \(id)",
        video: false,
        voteAverage: 6.8,
        voteCount: 45
    )
}
