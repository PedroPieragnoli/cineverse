//
//  MovieDetailResponse.swift
//  Cineverse
//

import Foundation

struct MovieDetailResponse: Codable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let runtime: Int?
    let genres: [Genre]
}
