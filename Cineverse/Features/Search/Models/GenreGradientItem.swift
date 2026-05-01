//
//  GenreGradientItem.swift
//  Cineverse
//

import SwiftUI

struct GenreGradientStyle: Equatable {
    let startColor: Color
    let endColor: Color

    var linearGradient: LinearGradient {
        LinearGradient(
            colors: [startColor, endColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct GenreGradientItem: Identifiable {
    let genre: Genre
    let style: GenreGradientStyle

    var id: Int { genre.id }

    var linearGradient: LinearGradient {
        style.linearGradient
    }
}
