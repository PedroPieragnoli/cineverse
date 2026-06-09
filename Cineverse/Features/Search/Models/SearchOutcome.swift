//
//  SearchOutcome.swift
//  Cineverse
//

import Foundation

enum SearchOutcome: Equatable {
    case error
    case empty
    case results(count: Int)

    var announcement: String {
        switch self {
        case .error:
            String(localized: "search.errorState.title")
        case .empty:
            String(localized: "search.emptyState.title")
        case let .results(count):
            String.localizedStringWithFormat(
                String(localized: "search.results.count.accessibilityAnnouncement"),
                count
            )
        }
    }
}
