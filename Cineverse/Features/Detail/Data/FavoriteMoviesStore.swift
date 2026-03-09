//
//  FavoriteMoviesStore.swift
//  Cineverse
//

import Foundation

protocol FavoriteMoviesStore: Sendable {
    func contains(_ movieID: Int) -> Bool
    @discardableResult
    func toggle(_ movieID: Int) -> Bool
}
