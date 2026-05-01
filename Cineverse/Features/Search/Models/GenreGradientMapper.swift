//
//  GenreGradientMapper.swift
//  Cineverse
//

import SwiftUI

enum GenreGradientMapper {
    static let palette: [GenreGradientStyle] = [
        make("#0A1628", "#4682B4"),
        make("#0B3D0B", "#2E8B57"),
        make("#2E0854", "#9B72CF"),
        make("#7A4400", "#CC7722"),
        make("#1A1A2E", "#6C6C80"),
        make("#2E3318", "#8B8044"),
        make("#1A1A1A", "#9B8A3D"),
        make("#0A3D3D", "#4AA8C0"),
        make("#3A0A5C", "#9B4D7A"),
        make("#3E2B16", "#8B7340"),
        make("#4A0000", "#1A0A0A"),
        make("#6B0A3D", "#C04060"),
        make("#0A0A2E", "#5A5A7A"),
        make("#5C0A3A", "#C06080"),
        make("#0A2E2E", "#3DA8A8"),
        make("#1E1E28", "#4A4A58"),
        make("#1A0A2E", "#5A5A6E"),
        make("#1E2E0A", "#6E7A5A"),
        make("#5C2E0A", "#B8956A")
    ]

    static func map(_ genres: [Genre]) -> [GenreGradientItem] {
        genres.enumerated().map { index, genre in
            GenreGradientItem(
                genre: genre,
                style: palette[paletteIndex(for: index)]
            )
        }
    }

    static func paletteIndex(for displayIndex: Int) -> Int {
        guard !palette.isEmpty else { return 0 }
        return displayIndex % palette.count
    }

    private static func make(_ startHex: String, _ endHex: String) -> GenreGradientStyle {
        GenreGradientStyle(
            startColor: Color(hex: startHex),
            endColor: Color(hex: endHex)
        )
    }
}
