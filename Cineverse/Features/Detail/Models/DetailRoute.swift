//
//  DetailRoute.swift
//  Cineverse
//

import CoreGraphics
import Foundation

struct DetailRoute: Identifiable, Hashable {
    enum Source: Hashable {
        case posterCard
        case hero

        var id: String {
            switch self {
            case .posterCard:
                return "poster"
            case .hero:
                return "hero"
            }
        }
    }

    let movie: Movie
    let source: Source
    let sourcePosterFrame: CGRect?
    let customTransitionSourceID: String?
    let sourceCornerRadius: CGFloat?
    let sourcePosterURL: URL?

    init(
        movie: Movie,
        source: Source,
        sourcePosterFrame: CGRect? = nil,
        customTransitionSourceID: String? = nil,
        sourceCornerRadius: CGFloat? = nil,
        sourcePosterURL: URL? = nil
    ) {
        self.movie = movie
        self.source = source
        self.sourcePosterFrame = sourcePosterFrame
        self.customTransitionSourceID = customTransitionSourceID
        self.sourceCornerRadius = sourceCornerRadius
        self.sourcePosterURL = sourcePosterURL
    }

    var id: String {
        "\(movie.id)-\(source.id)"
    }

    static func == (lhs: DetailRoute, rhs: DetailRoute) -> Bool {
        lhs.movie.id == rhs.movie.id && lhs.source == rhs.source
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(movie.id)
        hasher.combine(source)
    }

    var transitionSourceID: String? {
        guard source == .posterCard else {
            return nil
        }
        return customTransitionSourceID ?? Self.transitionSourceID(for: movie.id)
    }

    static func transitionSourceID(for movieID: Int) -> String {
        "movie-poster-\(movieID)"
    }
}
