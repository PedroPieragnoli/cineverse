//
//  HorizontalMovieCarousel.swift
//  Cineverse
//

import SwiftUI

struct HorizontalMovieCarousel<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content

    init(spacing: CGFloat = DesignSystem.Spacing.sm, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing) {
                content()
            }
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Movie Poster Carousel") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Trending")
                    .font(DesignSystem.Typography.sectionTitle)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
            HorizontalMovieCarousel {
                ForEach(Movie.mockArray) { movie in
                    MoviePosterCardView(movie: movie)
                }
            }
        }
    }
}
#endif
