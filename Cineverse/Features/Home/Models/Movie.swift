//
//  Movie.swift
//  Cineverse
//

import Foundation

struct Movie: Codable, Identifiable, Hashable {
    let id: Int
    let adult: Bool
    let backdropPath: String?
    let genreIds: [Int]
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String?
    let releaseDate: String
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case adult
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

    // MARK: - Computed Properties

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return TMDBConfiguration.posterURL(for: posterPath, size: .large)
    }

    var backdropURL: URL? {
        guard let backdropPath else { return nil }
        return TMDBConfiguration.backdropURL(for: backdropPath, size: .original)
    }

    var formattedReleaseDate: String {
        guard let date = DateFormatter.tmdbDateParser.date(from: releaseDate) else {
            return releaseDate
        }

        return DateFormatter.movieDisplayDate.string(from: date)
    }

    var ratingPercentage: Int {
        Int(voteAverage * 10)
    }

    var ratingFormatted: String {
        String(format: "%.1f", voteAverage)
    }
}
