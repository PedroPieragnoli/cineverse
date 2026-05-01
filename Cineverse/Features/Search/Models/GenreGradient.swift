//
//  GenreGradient.swift
//  Cineverse
//

import SwiftUI

struct GenreGradient: Identifiable {
    let genre: Genre
    let startColor: Color
    let endColor: Color

    var id: Int { genre.id }

    var linearGradient: LinearGradient {
        LinearGradient(
            colors: [startColor, endColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func gradient(for genreID: Int) -> GenreGradient? {
        lookup[genreID]
    }

    // MARK: - Catalog

    static let all: [GenreGradient] = [
        make(28, "Action", "#0A1628", "#4682B4"),
        make(12, "Adventure", "#0B3D0B", "#2E8B57"),
        make(16, "Animation", "#2E0854", "#9B72CF"),
        make(35, "Comedy", "#7A4400", "#CC7722"),
        make(80, "Crime", "#1A1A2E", "#6C6C80"),
        make(99, "Documentary", "#2E3318", "#8B8044"),
        make(18, "Drama", "#1A1A1A", "#9B8A3D"),
        make(10751, "Family", "#0A3D3D", "#4AA8C0"),
        make(14, "Fantasy", "#3A0A5C", "#9B4D7A"),
        make(36, "History", "#3E2B16", "#8B7340"),
        make(27, "Horror", "#4A0000", "#1A0A0A"),
        make(10402, "Music", "#6B0A3D", "#C04060"),
        make(9648, "Mystery", "#0A0A2E", "#5A5A7A"),
        make(10749, "Romance", "#5C0A3A", "#C06080"),
        make(878, "Science Fiction", "#0A2E2E", "#3DA8A8"),
        make(10770, "TV Movie", "#1E1E28", "#4A4A58"),
        make(53, "Thriller", "#1A0A2E", "#5A5A6E"),
        make(10752, "War", "#1E2E0A", "#6E7A5A"),
        make(37, "Western", "#5C2E0A", "#B8956A")
    ]

    private static let lookup: [Int: GenreGradient] = {
        Dictionary(uniqueKeysWithValues: all.map { ($0.genre.id, $0) })
    }()

    private static func make(
        _ id: Int,
        _ name: String,
        _ startHex: String,
        _ endHex: String
    ) -> GenreGradient {
        GenreGradient(
            genre: Genre(id: id, name: name),
            startColor: Color(hex: startHex),
            endColor: Color(hex: endHex)
        )
    }
}
