//
//  SearchResultRowItemTests.swift
//  CineverseTests
//

import Testing
@testable import Cineverse

struct SearchResultRowItemTests {
    private let allGenres = [
        Genre(id: 28, name: "Action"),
        Genre(id: 12, name: "Adventure"),
        Genre(id: 878, name: "Science Fiction"),
        Genre(id: 16, name: "Animation"),
        Genre(id: 10751, name: "Family"),
        Genre(id: 14, name: "Fantasy"),
        Genre(id: 35, name: "Comedy")
    ]

    @Test("Resolves genre names from movie genre IDs")
    func resolvesGenreNames() {
        let item = SearchResultRowItem(movie: .mock, allGenres: allGenres)

        #expect(item.genreNames == ["Action", "Adventure"])
    }

    @Test("Limits genre names to 2")
    func limitsGenreNamesToTwo() {
        let item = SearchResultRowItem(movie: .mockMario, allGenres: allGenres)

        #expect(item.genreNames.count == 2)
        #expect(item.genreNames == ["Animation", "Adventure"])
    }

    @Test("Builds subtitle with year and genres")
    func buildsSubtitleWithYearAndGenres() {
        let item = SearchResultRowItem(movie: .mock, allGenres: allGenres)

        #expect(item.subtitle == "2023 \u{2022} Action, Adventure")
    }

    @Test("Builds subtitle with year only when no genres match")
    func buildsSubtitleWithYearOnly() {
        let item = SearchResultRowItem(movie: .mock, allGenres: [])

        #expect(item.subtitle == "2023")
    }

    @Test("Builds subtitle with genres only when no release date")
    func buildsSubtitleWithGenresOnly() {
        let movie = makeMovie(releaseDate: nil, genreIds: [28, 12])
        let item = SearchResultRowItem(movie: movie, allGenres: allGenres)

        #expect(item.subtitle == "Action, Adventure")
    }

    @Test("Empty subtitle when no year and no matching genres")
    func emptySubtitle() {
        let movie = makeMovie(releaseDate: nil, genreIds: [])
        let item = SearchResultRowItem(movie: movie, allGenres: allGenres)

        #expect(item.subtitle.isEmpty)
    }

    @Test("Has rating when vote average is positive")
    func hasRatingWhenPositive() {
        let item = SearchResultRowItem(movie: .mock, allGenres: allGenres)

        #expect(item.hasRating == true)
        #expect(item.ratingPercentage == 65)
    }

    @Test("Has no rating when vote average is zero")
    func hasNoRatingWhenZero() {
        let item = SearchResultRowItem(movie: .mockWithoutPoster, allGenres: allGenres)

        #expect(item.hasRating == false)
    }

    @Test("Poster URL uses thumbnail size")
    func posterURLUsesThumbnailSize() {
        let item = SearchResultRowItem(movie: .mock, allGenres: allGenres)

        #expect(item.posterURL?.absoluteString.contains("w185") == true)
    }

    @Test("Poster URL is nil when movie has no poster")
    func posterURLIsNilWhenNoPoster() {
        let item = SearchResultRowItem(movie: .mockWithoutPoster, allGenres: allGenres)

        #expect(item.posterURL == nil)
    }

    // MARK: - Helpers

    private func makeMovie(
        releaseDate: String?,
        genreIds: [Int]
    ) -> Movie {
        Movie(
            id: 999,
            adult: false,
            backdropPath: nil,
            genreIds: genreIds,
            originalLanguage: "en",
            originalTitle: "Test Movie",
            overview: "Test overview",
            popularity: 1.0,
            posterPath: nil,
            releaseDate: releaseDate,
            title: "Test Movie",
            video: false,
            voteAverage: 0.0,
            voteCount: 0
        )
    }
}
