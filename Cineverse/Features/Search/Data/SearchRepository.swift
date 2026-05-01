//
//  SearchRepository.swift
//  Cineverse
//

import Foundation

protocol SearchRepository {
    func searchMovies(query: String, page: Int) async throws -> MovieResponse
    func fetchGenres() async throws -> [Genre]
}
