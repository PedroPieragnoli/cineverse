//
//  FeaturedMovieTests.swift
//  CineverseTests
//

import Testing
@testable import Cineverse
import Foundation

struct FeaturedMovieTests {
    @Test("Identifier remains tied to movie id")
    func identifierFromMovie() {
        let featuredMovie = FeaturedMovie(
            movie: makeMovie(id: 42, releaseDate: "2025-01-01", genreIds: []),
            allGenres: []
        )
        #expect(featuredMovie.id == 42)
    }

    @Test("Metadata uses display separator and limits genres to two")
    func metadataUsesDisplaySeparatorAndGenreLimit() {
        let featuredMovie = FeaturedMovie(
            movie: makeMovie(releaseDate: "2025-01-01", genreIds: [1, 2, 3]),
            allGenres: [makeGenre(id: 1, "Action"), makeGenre(id: 2, "Adventure"), makeGenre(id: 3, "Comedy")]
        )

        #expect(featuredMovie.metadataText == "2025 • Action • Adventure")
    }

    @Test("Accessibility metadata uses comma separator and limits genres to two")
    func accessibilityMetadataUsesCommaSeparator() {
        let featuredMovie = FeaturedMovie(
            movie: makeMovie(releaseDate: "2025-01-01", genreIds: [1, 2, 3]),
            allGenres: [makeGenre(id: 1, "Action"), makeGenre(id: 2, "Adventure"), makeGenre(id: 3, "Comedy")]
        )

        #expect(featuredMovie.accessibilityMetadataText == "2025, Action, Adventure")
    }

    @Test("Metadata includes only release year when no genres are provided")
    func metadataWithNoGenres() {
        let featuredMovie = FeaturedMovie(
            movie: makeMovie(releaseDate: "2025-01-01", genreIds: []),
            allGenres: []
        )
        #expect(featuredMovie.metadataText == "2025")
        #expect(featuredMovie.accessibilityMetadataText == "2025")
    }

    @Test("Metadata includes only genres when release date is invalid")
    func metadataWithInvalidReleaseDate() {
        let featuredMovie = FeaturedMovie(
            movie: makeMovie(releaseDate: "invalid-date", genreIds: [1, 2]),
            allGenres: [makeGenre(id: 1, "Action"), makeGenre(id: 2, "Adventure")]
        )

        #expect(featuredMovie.metadataText == "Action • Adventure")
        #expect(featuredMovie.accessibilityMetadataText == "Action, Adventure")
    }

    @Test("Metadata is empty when release date is invalid and genres are empty")
    func metadataWithNoReleaseYearAndNoGenres() {
        let featuredMovie = FeaturedMovie(
            movie: makeMovie(releaseDate: "invalid-date", genreIds: []),
            allGenres: []
        )
        #expect(featuredMovie.metadataText.isEmpty)
        #expect(featuredMovie.accessibilityMetadataText.isEmpty)
    }

    @Test("Metadata respects movie.genreIds ordering and ignores unknown ids")
    func metadataUsesMovieGenreOrderAndSkipsUnknownIds() {
        let featuredMovie = FeaturedMovie(
            movie: makeMovie(releaseDate: "2025-01-01", genreIds: [2, 1, 999]),
            allGenres: [makeGenre(id: 1, "Action"), makeGenre(id: 2, "Drama")]
        )

        #expect(featuredMovie.metadataText == "2025 • Drama • Action")
        #expect(featuredMovie.accessibilityMetadataText == "2025, Drama, Action")
    }

    // MARK: - Helpers

    private func makeMovie(
        id: Int = 1,
        title: String = "Sample Movie",
        releaseDate: String,
        genreIds: [Int]
    ) -> Movie {
        Movie(
            id: id,
            adult: false,
            backdropPath: nil,
            genreIds: genreIds,
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

    private func makeGenre(id: Int, _ name: String) -> Genre {
        Genre(id: id, name: name)
    }
}
