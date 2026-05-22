//
//  SearchRemoteDataSource.swift
//  Cineverse
//

import Foundation

protocol SearchRemoteDataSource {
    func searchMovies(query: String, page: Int) async throws -> MovieResponse
    func fetchGenres() async throws -> GenreResponse
    func discoverMovies(genreID: Int, page: Int) async throws -> MovieResponse
}
