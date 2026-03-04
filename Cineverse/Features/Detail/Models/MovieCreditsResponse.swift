//
//  MovieCreditsResponse.swift
//  Cineverse
//

import Foundation

struct MovieCreditsResponse: Codable, Hashable {
    let cast: [MovieCastResponse]
}

struct MovieCastResponse: Codable, Hashable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let order: Int?
}
