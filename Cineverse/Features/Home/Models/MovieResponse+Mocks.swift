//
//  MovieResponse+Mocks.swift
//  Cineverse
//

#if DEBUG
import Foundation

extension MovieResponse {
    static let mock = MovieResponse(
        page: 1,
        results: Movie.mockArray,
        totalPages: 38020,
        totalResults: 760385
    )

    static let empty = MovieResponse(
        page: 1,
        results: [],
        totalPages: 1,
        totalResults: 0
    )
}
#endif
