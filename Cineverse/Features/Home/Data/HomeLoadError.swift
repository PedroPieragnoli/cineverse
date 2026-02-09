//
//  HomeLoadError.swift
//  Cineverse
//

import Foundation

enum HomeLoadError: Error, Equatable {
    case missingTMDBToken
    case network
    case decoding
    case emptyCriticalContent
}

extension HomeLoadError {
    static func map(_ error: Error) -> HomeLoadError {
        if let homeError = error as? HomeLoadError {
            return homeError
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

    static func prioritized(from errors: [Error?]) -> HomeLoadError? {
        let mappedErrors = errors.compactMap { error in
            error.map(Self.map)
        }

        let priorities: [HomeLoadError] = [
            .missingTMDBToken,
            .decoding,
            .network
        ]

        for priority in priorities where mappedErrors.contains(priority) {
            return priority
        }

        return mappedErrors.first
    }
}
