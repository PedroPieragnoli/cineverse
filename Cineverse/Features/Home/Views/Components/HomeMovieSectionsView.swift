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
    let hiddenTransitionSourceID: String?
    let onContinueWatchingTapped: (ContinueWatchingItem) -> Void
    let onMovieTapped: (Movie, CGRect?, String) -> Void

    @State private var posterFramesByTransitionID: [String: CGRect] = [:]

    var body: some View {
        VStack(spacing: Layout.sectionGap) {
            ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                sectionView(section, sectionIndex: index)
            }
        }
        .padding(.top, Layout.headerTopPadding)
        .padding(.bottom, tabBarAwareBottomPadding)
        .onPreferenceChange(MoviePosterFramePreferenceKey.self) { newFrames in
            posterFramesByTransitionID = newFrames
        }
    }

    private var tabBarAwareBottomPadding: CGFloat {
        DesignSystem.Layout.tabBarHeight + safeAreaBottomInset + Layout.bottomContentGap
    }

    @ViewBuilder
    private func sectionView(_ section: HomeSection, sectionIndex: Int) -> some View {
        switch section {
        case let .continueWatching(items):
            continueWatchingSection(items)
        case let .movieCarousel(title, movies):
            movieCarouselSection(title: title, movies: movies, sectionIndex: sectionIndex)
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

    private func movieCarouselSection(
        title: String,
        movies: [Movie],
        sectionIndex: Int
    ) -> some View {
        sectionContainer(title: title) {
            HorizontalMovieCarousel {
                ForEach(Array(movies.enumerated()), id: \.element.id) { movieIndex, movie in
                    let transitionSourceID = transitionSourceID(
                        movieID: movie.id,
                        sectionIndex: sectionIndex,
                        movieIndex: movieIndex
                    )
                    let isHiddenSourcePoster = hiddenTransitionSourceID == transitionSourceID
                    MoviePosterCardView(movie: movie) {
                        onMovieTapped(
                            movie,
                            posterFramesByTransitionID[transitionSourceID],
                            transitionSourceID
                        )
                    }
                    .opacity(isHiddenSourcePoster ? 0 : 1)
                    .allowsHitTesting(!isHiddenSourcePoster)
                    .accessibilityHidden(isHiddenSourcePoster)
                    .background {
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: MoviePosterFramePreferenceKey.self,
                                value: [transitionSourceID: geometry.frame(in: .global)]
                            )
                        }
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

    private func transitionSourceID(
        movieID: Int,
        sectionIndex: Int,
        movieIndex: Int
    ) -> String {
        "\(DetailRoute.transitionSourceID(for: movieID))-\(sectionIndex)-\(movieIndex)"
    }
}

private struct MoviePosterFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}
