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
}
#endif
