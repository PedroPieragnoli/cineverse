//
//  MovieCastMember.swift
//  Cineverse
//

import Foundation

struct MovieCastMember: Identifiable, Hashable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?

    var profileURL: URL? {
        guard let profilePath, !profilePath.isEmpty else {
            return nil
        }
        return TMDBConfiguration.posterURL(for: profilePath, size: .small)
    }
}
