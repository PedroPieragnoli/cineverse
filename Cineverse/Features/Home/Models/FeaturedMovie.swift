//
//  FeaturedMovie.swift
//  Cineverse
//

import Foundation

struct FeaturedMovie: Identifiable, Hashable {
    private enum Constants {
        static let maxDisplayedGenres = 2
        static let displaySeparator = " • "
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
    var overview: String { movie.overview }
    var backdropURL: URL? { movie.backdropURL }

    var metadataText: String { formattedMetadata(separator: Constants.displaySeparator) }
    var accessibilityMetadataText: String { formattedMetadata(separator: Constants.accessibilitySeparator) }

    private func formattedMetadata(separator: String) -> String {
        [movie.releaseYear ?? "", formattedGenres(separator: separator)]
            .filter { !$0.isEmpty }
            .joined(separator: separator)
    }

    private func formattedGenres(separator: String) -> String {
        matchedGenres
            .prefix(Constants.maxDisplayedGenres)
            .map(\.name)
            .joined(separator: separator)
    }
}
