//
//  HomeMovieSectionsView.swift
//  Cineverse
//

import SwiftUI

struct HomeMovieSectionsView: View {
    private enum Layout {
        static let sectionGap: CGFloat = 40
        static let sectionSpacing: CGFloat = 24
        static let headerTopPadding: CGFloat = 8
        static let bottomContentGap: CGFloat = DesignSystem.Spacing.xl
    }

    let sections: [HomeSection]
    let safeAreaBottomInset: CGFloat
    let onContinueWatchingTapped: (ContinueWatchingItem) -> Void
    let onMovieTapped: (Movie) -> Void

    var body: some View {
        VStack(spacing: Layout.sectionGap) {
            ForEach(sections) { section in
                sectionView(section)
            }
        }
        .padding(.top, Layout.headerTopPadding)
        .padding(.bottom, tabBarAwareBottomPadding)
    }

    private var tabBarAwareBottomPadding: CGFloat {
        DesignSystem.Layout.tabBarHeight + safeAreaBottomInset + Layout.bottomContentGap
    }

    @ViewBuilder
    private func sectionView(_ section: HomeSection) -> some View {
        switch section {
        case let .continueWatching(items):
            continueWatchingSection(items)
        case let .movieCarousel(title, movies):
            movieCarouselSection(title: title, movies: movies)
        }
    }

    private func continueWatchingSection(_ items: [ContinueWatchingItem]) -> some View {
        sectionContainer(title: String(localized: "continueWatching.sectionTitle")) {
            HorizontalMovieCarousel(spacing: DesignSystem.Spacing.md) {
                ForEach(items) { item in
                    ContinueWatchingCardView(item: item) {
                        onContinueWatchingTapped(item)
                    }
                }
            }
        }
    }

    private func movieCarouselSection(title: String, movies: [Movie]) -> some View {
        sectionContainer(title: title) {
            HorizontalMovieCarousel {
                ForEach(movies) { movie in
                    MoviePosterCardView(movie: movie) {
                        onMovieTapped(movie)
                    }
                }
            }
        }
    }

    private func sectionContainer<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            sectionTitle(title)
            content()
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.sectionTitle)
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}
