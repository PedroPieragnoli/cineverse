//
//  PreviewSearchRepository.swift
//  Cineverse
//

#if DEBUG
import Foundation

struct PreviewSearchRepository: SearchRepository {
    enum Behavior {
        case normal
        case delayedForever
        case alwaysFailing
    }

    var searchResult: MovieResponse
    var genres: [Genre]
    var discoverResult: MovieResponse
    var behavior: Behavior

    init(
        searchResult: MovieResponse = .mock,
        genres: [Genre] = Genre.mockArray,
        discoverResult: MovieResponse = .mock,
        behavior: Behavior = .normal
    ) {
        self.searchResult = searchResult
        self.genres = genres
        self.discoverResult = discoverResult
        self.behavior = behavior
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResponse {
        try await apply(returning: searchResult)
    }

    func fetchGenres() async throws -> [Genre] {
        try await apply(returning: genres)
    }

    func discoverMovies(genreID: Int, page: Int) async throws -> MovieResponse {
        try await apply(returning: discoverResult)
    }

    private func apply<Value>(returning value: Value) async throws -> Value {
        switch behavior {
        case .normal:
            return value
        case .delayedForever:
            try await Task.sleep(for: .seconds(Double.greatestFiniteMagnitude))
            return value
        case .alwaysFailing:
            throw URLError(.notConnectedToInternet)
        }
    }
}
#endif
