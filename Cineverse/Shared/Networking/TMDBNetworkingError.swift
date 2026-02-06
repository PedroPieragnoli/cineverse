//
//  TMDBNetworkingError.swift
//  Cineverse
//

import Foundation

enum TMDBNetworkingError: Error, Equatable {
    case missingTMDBToken
    case network
    case decoding
}
