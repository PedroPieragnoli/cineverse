//
//  HomeRemoteDataSource.swift
//  Cineverse
//

import Foundation

protocol HomeRemoteDataSource: Sendable {
    func fetchTrending() async throws -> MovieResponse
    func fetchUpcoming() async throws -> MovieResponse
    func fetchGenres() async throws -> GenreResponse
}
