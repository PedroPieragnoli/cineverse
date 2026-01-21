//
//  HomeSection.swift
//  Cineverse
//

import Foundation

enum HomeSection: Identifiable {
    case continueWatching(items: [ContinueWatchingItem])
    case movieCarousel(title: String, movies: [Movie])

    var id: String {
        switch self {
        case .continueWatching:
            return "continue-watching"
        case let .movieCarousel(title, _):
            return "carousel-\(title)"
        }
    }

    var isEmpty: Bool {
        switch self {
        case let .continueWatching(items):
            return items.isEmpty
        case let .movieCarousel(_, movies):
            return movies.isEmpty
        }
    }
}
