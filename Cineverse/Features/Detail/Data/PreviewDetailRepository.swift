//
//  PreviewDetailRepository.swift
//  Cineverse
//

import Foundation

#if DEBUG
struct PreviewDetailRepository: DetailRepository {
    private let payload: MovieDetailPayload

    init(payload: MovieDetailPayload = .previewPayload) {
        self.payload = payload
    }

    func fetchDetail(movieID: Int) async throws -> MovieDetailPayload {
        payload
    }
}

private extension MovieDetailPayload {
    static let previewPayload = MovieDetailPayload(
        detail: MovieDetailResponse(
            id: Movie.mock.id,
            title: Movie.mock.title,
            overview: Movie.mock.overview,
            posterPath: Movie.mock.posterPath,
            releaseDate: Movie.mock.releaseDate,
            voteAverage: Movie.mock.voteAverage,
            runtime: 166,
            genres: [.scienceFiction, .adventure]
        ),
        cast: [
            MovieCastMember(id: 1, name: "T. Chalamet", character: "Paul Atreides", profilePath: nil),
            MovieCastMember(id: 2, name: "Zendaya", character: "Chani", profilePath: nil),
            MovieCastMember(id: 3, name: "Austin Butler", character: "Feyd-Rautha", profilePath: nil)
        ]
    )
}
#endif
