//
//  SearchResultRowItem.swift
//  Cineverse
//

import Foundation

struct SearchResultRowItem: Identifiable {
    private enum Constants {
        static let maxDisplayedGenres = 2
        static let genreSeparator = ", "
        static let displaySeparator = " \u{2022} "
        static let accessibilitySeparator = ", "
    }

    let movie: Movie
    private let matchedGenres: [Genre]

    init(movie: Movie, allGenres: [Genre]) {
        self.movie = movie

        let genresById = Dictionary(uniqueKeysWithValues: allGenres.map { ($0.id, $0) })
        self.matchedGenres = movie.genreIds.compactMap { genresById[$0] }
    }

    var id: Int { movie.id }
    var title: String { movie.title }
    var posterURL: URL? { movie.thumbnailPosterURL }
    var releaseYear: String { movie.releaseYear ?? "" }
    var ratingPercentage: Int { movie.ratingPercentage }
    var hasRating: Bool { movie.voteAverage > 0 }

    var genreNames: [String] {
        matchedGenres
            .prefix(Constants.maxDisplayedGenres)
            .map(\.name)
    }

    var subtitle: String { formattedSubtitle(separator: Constants.displaySeparator) }
    var accessibilitySubtitle: String { formattedSubtitle(separator: Constants.accessibilitySeparator) }

    var scoreText: String {
        String(format: String(localized: "search.result.score"), ratingPercentage)
    }

    var accessibilityScoreText: String {
        String(format: String(localized: "search.result.score.accessibilityLabel"), ratingPercentage)
    }

    private func formattedSubtitle(separator: String) -> String {
        let genres = genreNames.joined(separator: Constants.genreSeparator)
        return [releaseYear, genres]
            .filter { !$0.isEmpty }
            .joined(separator: separator)
    }
}

// MARK: - Mocks

#if DEBUG
extension SearchResultRowItem {
    static let mock = SearchResultRowItem(movie: .mock, allGenres: Genre.mockArray)
    static let mockMario = SearchResultRowItem(movie: .mockMario, allGenres: Genre.mockArray)
    static let mockShazam = SearchResultRowItem(movie: .mockShazam, allGenres: Genre.mockArray)
    static let mockAvatar = SearchResultRowItem(movie: .mockAvatar, allGenres: Genre.mockArray)
    static let mockNoPoster = SearchResultRowItem(movie: .mockWithoutPoster, allGenres: Genre.mockArray)

    static let mockArray = [mock, mockMario, mockShazam, mockAvatar, mockNoPoster]
}
#endif
