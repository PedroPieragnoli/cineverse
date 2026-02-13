//
//  PreviewHomeRepository.swift
//  Cineverse
//

import Foundation

#if DEBUG
struct PreviewHomeRepository: HomeRepository {
    private let payload: HomePayload

    init(payload: HomePayload = .previewPayload) {
        self.payload = payload
    }

    func fetchHomePayload() async throws -> HomePayload {
        payload
    }
}

private extension HomePayload {
    static let previewPayload = HomePayload(
        featuredMovie: .mockMario,
        trendingMovies: Movie.mockArray,
        newReleases: Array(Movie.mockArray.reversed()),
        continueWatching: ContinueWatchingItem.mockArray
    )
}
#endif
