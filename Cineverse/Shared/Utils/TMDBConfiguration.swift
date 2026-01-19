//
//  TMDBConfiguration.swift
//  Cineverse
//

import Foundation

enum TMDBConfiguration {
    static let imageBaseURL = "https://image.tmdb.org/t/p"

    enum PosterSize: String {
        case thumbnail = "w92"
        case extraSmall = "w154"
        case small = "w185"
        case medium = "w342"
        case large = "w500"
        case extraLarge = "w780"
        case original = "original"
    }

    enum BackdropSize: String {
        case small = "w300"
        case medium = "w780"
        case large = "w1280"
        case original = "original"
    }

    static func posterURL(for path: String, size: PosterSize = .large) -> URL? {
        guard !path.isEmpty else {
            return nil
        }

        return URL(string: "\(imageBaseURL)/\(size.rawValue)\(path)")
    }

    static func backdropURL(for path: String, size: BackdropSize = .original) -> URL? {
        guard !path.isEmpty else {
            return nil
        }

        return URL(string: "\(imageBaseURL)/\(size.rawValue)\(path)")
    }
}
