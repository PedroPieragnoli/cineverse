//
//  MovieDetailPayload.swift
//  Cineverse
//

import Foundation

struct MovieDetailPayload: Hashable {
    let detail: MovieDetailResponse
    let cast: [MovieCastMember]

    var title: String {
        detail.title
    }

    var overview: String {
        detail.overview
    }

    var posterURL: URL? {
        guard let posterPath = detail.posterPath, !posterPath.isEmpty else {
            return nil
        }
        return TMDBConfiguration.posterURL(for: posterPath, size: .large)
    }

    var ratingPercentage: Int {
        min(max(Int(detail.voteAverage * 10), 0), 100)
    }

    var releaseYear: String? {
        guard let releaseDate = detail.releaseDate else {
            return nil
        }

        let components = releaseDate.split(separator: "-")
        guard let year = components.first, year.count == 4 else {
            return nil
        }

        return String(year)
    }

    var runtimeMinutes: Int? {
        detail.runtime
    }

    var genres: [Genre] {
        detail.genres
    }

    var topGenres: [Genre] {
        Array(detail.genres.prefix(2))
    }
}
