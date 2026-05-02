//
//  SearchLoadError.swift
//  Cineverse
//

import Foundation

enum SearchLoadError: Error, Equatable {
    case missingTMDBToken
    case network
    case decoding
}

extension SearchLoadError {
    static func map(_ error: Error) -> SearchLoadError {
        if let searchError = error as? SearchLoadError {
            return searchError
        }

        if let networkingError = error as? TMDBNetworkingError {
            switch networkingError {
            case .missingTMDBToken:
                return .missingTMDBToken
            case .network:
                return .network
            case .decoding:
                return .decoding
            }
        }

        return .network
    }
}
