//
//  HomeView.swift
//  Cineverse
//

import SwiftUI

struct HomeView: View {
    // MARK: - Properties

    private let viewModel: HomeViewModel
    @State private var scrollOffset: CGFloat = 0

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                scrollContent(safeAreaBottomInset: geometry.safeAreaInsets.bottom)
                    .ignoresSafeArea()
                headerOverlay
            }
            .background(DesignSystem.Colors.background)
            .task {
                await viewModel.loadInitialData()
            }
        }
    }

    // MARK: - Computed Properties

    private var headerOpacity: Double {
        min(0.9, max(0, scrollOffset / 200))
    }

    // MARK: - Subviews

    private var headerOverlay: some View {
        HomeHeaderView(backgroundOpacity: headerOpacity)
    }

    private func scrollContent(safeAreaBottomInset: CGFloat) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroSection
                HomeMovieSectionsView(
                    sections: viewModel.sections,
                    safeAreaBottomInset: safeAreaBottomInset,
                    onContinueWatchingTapped: handleContinueWatchingTapped,
                    onMovieTapped: handleMovieTapped
                )
            }
        }
        .coordinateSpace(name: HomeCoordinateSpace.scroll)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newValue in
            scrollOffset = max(0, newValue)
        }
    }

    @ViewBuilder
    private var heroSection: some View {
        if let featured = viewModel.featuredMovie {
            HeroSectionView(
                featuredMovie: featured,
                onWatchTapped: { handleWatchTapped(featured) },
                onMyListTapped: { handleMyListTapped(featured) }
            )
            .containerRelativeFrame(.vertical) { length, _ in
                length * DesignSystem.Layout.heroHeightRatio
            }
        }
    }

    // MARK: - Actions

    private func handleWatchTapped(_ featured: FeaturedMovie) {
        viewModel.didTapWatch(featured)
    }

    private func handleMyListTapped(_ featured: FeaturedMovie) {
        viewModel.didTapMyList(featured)
    }

    private func handleContinueWatchingTapped(_ item: ContinueWatchingItem) {
        viewModel.didTapContinueWatching(item)
    }

    private func handleMovieTapped(_ movie: Movie) {
        viewModel.didTapMovie(movie)
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Home View") {
    HomeView(viewModel: HomeViewModel(repository: PreviewHomeRepository()))
        .preferredColorScheme(.dark)
}

#Preview("Home View - Loading") {
    HomeView(viewModel: HomeViewModel(repository: PreviewHomeRepository()))
        .preferredColorScheme(.dark)
}
#endif
