//
//  MovieDetailPayloadTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct MovieDetailPayloadTests {

    // MARK: - ratingPercentage

    @Test("ratingPercentage scales voteAverage to 0...100")
    func ratingPercentageScales() {
        let payload = makePayload(voteAverage: 7.5)

        #expect(payload.ratingPercentage == 75)
    }

    @Test("ratingPercentage clamps negative voteAverage to 0")
    func ratingPercentageClampsNegative() {
        let payload = makePayload(voteAverage: -2.5)

        #expect(payload.ratingPercentage == 0)
    }

    @Test("ratingPercentage clamps voteAverage above 10 to 100")
    func ratingPercentageClampsAboveCeiling() {
        let payload = makePayload(voteAverage: 12.4)

        #expect(payload.ratingPercentage == 100)
    }

    @Test("ratingPercentage at the boundaries")
    func ratingPercentageBoundaries() {
        #expect(makePayload(voteAverage: 0).ratingPercentage == 0)
        #expect(makePayload(voteAverage: 10).ratingPercentage == 100)
    }

    // MARK: - releaseYear

    @Test("releaseYear extracts the year from a well-formed date")
    func releaseYearWellFormed() {
        let payload = makePayload(releaseDate: "2024-01-15")

        #expect(payload.releaseYear == "2024")
    }

    @Test("releaseYear is nil when releaseDate is nil")
    func releaseYearNil() {
        let payload = makePayload(releaseDate: nil)

        #expect(payload.releaseYear == nil)
    }

    @Test("releaseYear is nil when releaseDate is empty")
    func releaseYearEmpty() {
        let payload = makePayload(releaseDate: "")

        #expect(payload.releaseYear == nil)
    }

    @Test("releaseYear is nil when first segment is not a 4-digit year")
    func releaseYearMalformed() {
        #expect(makePayload(releaseDate: "abc-de").releaseYear == nil)
        #expect(makePayload(releaseDate: "24-01-15").releaseYear == nil)
        #expect(makePayload(releaseDate: "20240115").releaseYear == nil)
    }

    @Test("releaseYear accepts a year-only string")
    func releaseYearOnlyYear() {
        let payload = makePayload(releaseDate: "2024")

        #expect(payload.releaseYear == "2024")
    }

    // MARK: - topGenres

    @Test("topGenres returns an empty array when there are no genres")
    func topGenresEmpty() {
        let payload = makePayload(genres: [])

        #expect(payload.topGenres.isEmpty)
    }

    @Test("topGenres returns all genres when there are fewer than two")
    func topGenresLessThanTwo() {
        let payload = makePayload(genres: [Genre(id: 1, name: "Drama")])

        #expect(payload.topGenres.map(\.name) == ["Drama"])
    }

    @Test("topGenres caps at two genres when more are available")
    func topGenresCapsAtTwo() {
        let genres = [
            Genre(id: 1, name: "Drama"),
            Genre(id: 2, name: "Action"),
            Genre(id: 3, name: "Sci-Fi"),
            Genre(id: 4, name: "Thriller")
        ]
        let payload = makePayload(genres: genres)

        #expect(payload.topGenres.map(\.name) == ["Drama", "Action"])
    }

    // MARK: - posterURL

    @Test("posterURL returns nil when posterPath is nil")
    func posterURLNil() {
        let payload = makePayload(posterPath: nil)

        #expect(payload.posterURL == nil)
    }

    @Test("posterURL returns nil when posterPath is empty")
    func posterURLEmpty() {
        let payload = makePayload(posterPath: "")

        #expect(payload.posterURL == nil)
    }

    @Test("posterURL returns a URL when posterPath is non-empty")
    func posterURLValid() {
        let payload = makePayload(posterPath: "/abc.jpg")

        #expect(payload.posterURL != nil)
    }

    // MARK: - runtimeMinutes

    @Test("runtimeMinutes passes through detail.runtime")
    func runtimeMinutesPassesThrough() {
        #expect(makePayload(runtime: 120).runtimeMinutes == 120)
        #expect(makePayload(runtime: nil).runtimeMinutes == nil)
    }

    // MARK: - Helpers

    private func makePayload(
        voteAverage: Double = 7.0,
        releaseDate: String? = "2024-01-15",
        runtime: Int? = 120,
        genres: [Genre] = [Genre(id: 18, name: "Drama")],
        posterPath: String? = "/poster.jpg",
        cast: [MovieCastMember] = []
    ) -> MovieDetailPayload {
        MovieDetailPayload(
            detail: MovieDetailResponse(
                id: 1,
                title: "Test",
                overview: "Test overview",
                posterPath: posterPath,
                releaseDate: releaseDate,
                voteAverage: voteAverage,
                runtime: runtime,
                genres: genres
            ),
            cast: cast
        )
    }
}
