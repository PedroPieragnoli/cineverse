//
//  GenreCardView.swift
//  Cineverse
//

import SwiftUI

struct GenreCardView: View {
    private enum Layout {
        static let height: CGFloat = 100
    }

    let item: GenreGradientItem

    var body: some View {
        item.linearGradient
            .frame(height: Layout.height)
            .clipShape(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
            )
            .overlay(alignment: .bottomLeading) {
                genreLabel
            }
    }

    // MARK: - Subviews

    private var genreLabel: some View {
        Text(item.genre.name)
            .font(DesignSystem.Typography.genreCardTitle)
            .foregroundStyle(.white)
            .padding(.leading, DesignSystem.Spacing.sm)
            .padding(.bottom, DesignSystem.Spacing.sm)
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Action") {
    ZStack {
        Color.black.ignoresSafeArea()
        GenreCardView(item: GenreGradientMapper.map(SearchGenreMocks.all)[0])
            .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

#Preview("Animation") {
    ZStack {
        Color.black.ignoresSafeArea()
        GenreCardView(item: GenreGradientMapper.map(SearchGenreMocks.all)[2])
            .padding(.horizontal, DesignSystem.Spacing.md)
    }
}
#endif
