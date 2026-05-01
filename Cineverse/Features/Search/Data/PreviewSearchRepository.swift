//
//  PreviewSearchRepository.swift
//  Cineverse
//

#if DEBUG
import Foundation

struct PreviewSearchRepository: SearchRepository {
    var searchResult: MovieResponse
    var genres: [Genre]

    init(
        searchResult: MovieResponse = .mock,
        genres: [Genre] = Genre.mockArray
    ) {
        self.searchResult = searchResult
        self.genres = genres
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResponse {
        searchResult
    }

    func fetchGenres() async throws -> [Genre] {
        genres
    }
}
#endif
