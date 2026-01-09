//
//  Genre.swift
//  Cineverse
//

import Foundation

struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

struct GenreResponse: Codable {
    let genres: [Genre]
}
