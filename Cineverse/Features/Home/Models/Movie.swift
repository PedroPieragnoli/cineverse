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
    let releaseDate: String?
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    // MARK: - Computed Properties

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return TMDBConfiguration.posterURL(for: posterPath, size: .large)
    }

    var thumbnailPosterURL: URL? {
        guard let posterPath else { return nil }
        return TMDBConfiguration.posterURL(for: posterPath, size: .small)
    }

    var backdropURL: URL? {
        guard let backdropPath else { return nil }
        return TMDBConfiguration.backdropURL(for: backdropPath, size: .original)
    }

    var releaseYear: String? {
        guard let releaseDate, let date = MovieDateFormatter.parse(releaseDate) else {
            return nil
        }
        return MovieDateFormatter.releaseYear(from: date)
    }

    var formattedReleaseDate: String {
        guard let releaseDate else { return "" }

        guard let date = MovieDateFormatter.parse(releaseDate) else {
            return releaseDate
        }

        return MovieDateFormatter.formattedReleaseDate(from: date)
    }

    var ratingPercentage: Int {
        min(max(Int(voteAverage * 10), 0), 100)
    }

    var ratingFormatted: String {
        voteAverage.formatted(.number.precision(.fractionLength(1)))
    }
}

private enum MovieDateFormatter {
    private static let tmdbTimeZone = TimeZone(secondsFromGMT: 0) ?? .current

    private static let tmdbCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tmdbTimeZone
        return calendar
    }()

    private static let tmdbDateParseStrategy = Date.ParseStrategy(
        format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
        locale: Locale(identifier: "en_US_POSIX"),
        timeZone: tmdbTimeZone,
        calendar: tmdbCalendar
    )

    private static let releaseDateDisplayStyle: Date.FormatStyle = {
        var style = Date.FormatStyle(date: .abbreviated, time: .omitted)
        style.calendar = tmdbCalendar
        style.timeZone = tmdbTimeZone
        style.locale = Locale.current
        return style
    }()

    static func parse(_ dateString: String) -> Date? {
        try? tmdbDateParseStrategy.parse(dateString)
    }

    static func releaseYear(from date: Date) -> String {
        String(tmdbCalendar.component(.year, from: date))
    }

    static func formattedReleaseDate(from date: Date) -> String {
        date.formatted(releaseDateDisplayStyle)
    }
}
