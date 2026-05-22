//
//  GenreResultsHeroBanner.swift
//  Cineverse
//

import SwiftUI

struct GenreResultsHeroBanner: View {
    private enum Layout {
        static let height: CGFloat = 140
        static let titleBottomPadding: CGFloat = 20
    }

    let genre: Genre
    let gradient: GenreGradientStyle
    var topSafeAreaInset: CGFloat = 0

    var body: some View {
        gradient.linearGradient
            .frame(height: Layout.height + topSafeAreaInset)
            .overlay(alignment: .bottomLeading) {
                title
            }
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(Text(genre.name))
    }

    // MARK: - Subviews

    private var title: some View {
        Text(genre.name)
            .font(DesignSystem.Typography.heroTitle)
            .foregroundStyle(.white)
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
            .padding(.bottom, Layout.titleBottomPadding)
    }
}

// MARK: - Previews

#if DEBUG
private extension GenreResultsHeroBanner {
    static func preview(at index: Int) -> GenreResultsHeroBanner {
        let item = GenreGradientMapper.map(SearchGenreMocks.all)[index]
        return GenreResultsHeroBanner(genre: item.genre, gradient: item.style)
    }
}

#Preview("Action") {
    GenreResultsHeroBanner.preview(at: 0)
        .background(DesignSystem.Colors.background)
        .preferredColorScheme(.dark)
}

#Preview("Comedy") {
    GenreResultsHeroBanner.preview(at: 3)
        .background(DesignSystem.Colors.background)
        .preferredColorScheme(.dark)
}

#Preview("Horror") {
    GenreResultsHeroBanner.preview(at: 10)
        .background(DesignSystem.Colors.background)
        .preferredColorScheme(.dark)
}
#endif
