//
//  FeaturedMovie+Mocks.swift
//  Cineverse
//

import Foundation

#if DEBUG
extension FeaturedMovie {
    static let mock = FeaturedMovie(
        movie: .mockAvatar,
        allGenres: Genre.mockArray
    )

    static let mockAntMan = FeaturedMovie(
        movie: .mock,
        allGenres: Genre.mockArray
    )

    static let mockMario = FeaturedMovie(
        movie: .mockMario,
        allGenres: Genre.mockArray
    )
}
#endif
