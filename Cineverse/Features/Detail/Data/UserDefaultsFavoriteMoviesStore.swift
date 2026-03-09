//
//  UserDefaultsFavoriteMoviesStore.swift
//  Cineverse
//

import Foundation

// @unchecked: UserDefaults is documented thread-safe but not marked Sendable in Foundation.
struct UserDefaultsFavoriteMoviesStore: FavoriteMoviesStore, @unchecked Sendable {
    private enum Constants {
        static let favoritesKey = "favoriteMovieIDs"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func contains(_ movieID: Int) -> Bool {
        favoriteIDs.contains(movieID)
    }

    @discardableResult
    func toggle(_ movieID: Int) -> Bool {
        var updatedFavorites = favoriteIDs
        let wasFavorite = updatedFavorites.contains(movieID)

        if wasFavorite {
            updatedFavorites.remove(movieID)
        } else {
            updatedFavorites.insert(movieID)
        }

        userDefaults.set(Array(updatedFavorites), forKey: Constants.favoritesKey)
        return !wasFavorite
    }

    private var favoriteIDs: Set<Int> {
        let ids = userDefaults.array(forKey: Constants.favoritesKey) as? [Int] ?? []
        return Set(ids)
    }
}
