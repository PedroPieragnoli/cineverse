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
        NavigationLink(value: GenreResultsRoute(genre: item.genre, gradient: item.style)) {
            item.linearGradient
                .frame(height: Layout.height)
                .clipShape(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                )
                .overlay(alignment: .bottomLeading) {
                    genreLabel
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(item.genre.name))
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
private extension GenreCardView {
    static func preview(genreIndex: Int) -> some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                GenreCardView(item: GenreGradientMapper.map(SearchGenreMocks.all)[genreIndex])
                    .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }
}

#Preview("Action") {
    GenreCardView.preview(genreIndex: 0)
}

#Preview("Animation") {
    GenreCardView.preview(genreIndex: 2)
}
#endif
