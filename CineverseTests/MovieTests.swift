//
//  MovieTests.swift
//  CineverseTests
//

import Testing
@testable import Cineverse
import Foundation

struct MovieTests {
    private static let tmdbTimeZone = TimeZone(secondsFromGMT: 0) ?? .current

    private static let tmdbCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tmdbTimeZone
        return calendar
    }()

    private static let releaseDateDisplayStyle: Date.FormatStyle = {
        var style = Date.FormatStyle(date: .abbreviated, time: .omitted)
        style.calendar = tmdbCalendar
        style.timeZone = tmdbTimeZone
        style.locale = Locale.current
        return style
    }()

    @Test("releaseYear returns year for valid TMDB date")
    func releaseYearWithValidDate() {
        let movie = Self.makeMovie(releaseDate: "2025-12-17")
        #expect(movie.releaseYear == "2025")
    }

    @Test("releaseYear returns nil for invalid TMDB date")
    func releaseYearWithInvalidDate() {
        let movie = Self.makeMovie(releaseDate: "invalid-date")
        #expect(movie.releaseYear == nil)
    }

    @Test("releaseYear is nil and formattedReleaseDate is empty when releaseDate is nil")
    func releaseDateWithNilValue() {
        let movie = Self.makeMovie(releaseDate: nil)
        #expect(movie.releaseYear == nil)
        #expect(movie.formattedReleaseDate.isEmpty)
    }

    @Test("formattedReleaseDate returns localized date for valid TMDB date")
    func formattedReleaseDateWithValidDate() {
        let movie = Self.makeMovie(releaseDate: "2025-12-17")
        let expected = Self.utcDate(year: 2025, month: 12, day: 17).formatted(Self.releaseDateDisplayStyle)

        #expect(movie.formattedReleaseDate == expected)
        #expect(movie.formattedReleaseDate != movie.releaseDate)
    }

    @Test("formattedReleaseDate returns raw value for invalid TMDB date")
    func formattedReleaseDateWithInvalidDate() {
        let rawDate = "not-a-date"
        let movie = Self.makeMovie(releaseDate: rawDate)
        #expect(movie.formattedReleaseDate == rawDate)
    }

    // MARK: - Helpers

    private static func makeMovie(id: Int = 1, title: String = "Sample Movie", releaseDate: String?) -> Movie {
        Movie(
            id: id,
            adult: false,
            backdropPath: nil,
            genreIds: [],
            originalLanguage: "en",
            originalTitle: title,
            overview: "Overview",
            popularity: 0,
            posterPath: nil,
            releaseDate: releaseDate,
            title: title,
            video: false,
            voteAverage: 7,
            voteCount: 100
        )
    }

    private static func utcDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.calendar = tmdbCalendar
        components.timeZone = tmdbTimeZone
        components.year = year
        components.month = month
        components.day = day

        return components.date!
    }
}
