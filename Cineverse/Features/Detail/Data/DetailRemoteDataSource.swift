//
//  DetailRemoteDataSource.swift
//  Cineverse
//

import Foundation

protocol DetailRemoteDataSource: Sendable {
    func fetchMovieDetail(movieID: Int) async throws -> MovieDetailResponse
    func fetchCredits(movieID: Int) async throws -> MovieCreditsResponse
}
