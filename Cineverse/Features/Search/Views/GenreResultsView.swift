//
//  GenreResultsView.swift
//  Cineverse
//

import SwiftUI

struct GenreResultsView: View {
    private enum Layout {
        static let scrolledPastHeroThreshold: CGFloat = 120
    }

    let viewModel: GenreResultsViewModel
    let gradient: GenreGradientStyle
    var onDetailRequested: (DetailRoute) -> Void = { _ in }

    @State private var hasScrolledPastHero = false

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    GenreResultsHeroBanner(
                        genre: viewModel.genre,
                        gradient: gradient,
                        topSafeAreaInset: geometry.safeAreaInsets.top
                    )
                    phaseContent
                        .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
                        .padding(.top, DesignSystem.Spacing.md)
                }
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            .background(DesignSystem.Colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    collapsingNavTitle
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(hasScrolledPastHero ? .visible : .hidden, for: .navigationBar)
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top > Layout.scrolledPastHeroThreshold
            } action: { _, isPastHero in
                hasScrolledPastHero = isPastHero
            }
            .task {
                await viewModel.loadInitial()
            }
        }
    }

    // MARK: - Subviews

    private var collapsingNavTitle: some View {
        Text(viewModel.genre.name)
            .font(DesignSystem.Typography.navTitle)
            .foregroundStyle(.white)
            .opacity(hasScrolledPastHero ? 1 : 0)
            .accessibilityHidden(!hasScrolledPastHero)
            .animation(.easeInOut(duration: DesignSystem.Animation.quick), value: hasScrolledPastHero)
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch viewModel.phase {
        case .loading:
            SkeletonSearchResultsList()
        case .loaded:
            resultRows
        case .empty:
            SearchEmptyStateView(
                titleKey: "genre.results.empty.title",
                subtitleKey: "genre.results.empty.subtitle"
            )
        case .error:
            ErrorStateView(configuration: .searchError) {
                Task { await viewModel.retry() }
            }
        }
    }

    private var resultRows: some View {
        ForEach(Array(rowItems.enumerated()), id: \.element.id) { index, item in
            SearchResultRowView(
                item: item,
                showDivider: index < rowItems.count - 1,
                onTap: handleResultTapped
            )
        }
    }

    private var rowItems: [SearchResultRowItem] {
        viewModel.results.map { movie in
            SearchResultRowItem(movie: movie, allGenres: [viewModel.genre])
        }
    }

    // MARK: - Actions

    private func handleResultTapped(_ movie: Movie, frame: CGRect) {
        onDetailRequested(
            DetailRoute(
                movie: movie,
                source: .posterCard,
                sourcePosterFrame: frame,
                customTransitionSourceID: DetailRoute.transitionSourceID(for: movie.id),
                sourceCornerRadius: DesignSystem.CornerRadius.small,
                sourcePosterURL: movie.thumbnailPosterURL
            )
        )
    }
}

// MARK: - Previews

#if DEBUG
private extension GenreResultsView {
    static func preview(
        repository: PreviewSearchRepository,
        genreIndex: Int = 0
    ) -> some View {
        let styledGenre = GenreGradientMapper.map(SearchGenreMocks.all)[genreIndex]
        let viewModel = GenreResultsViewModel(genre: styledGenre.genre, repository: repository)
        return NavigationStack {
            GenreResultsView(viewModel: viewModel, gradient: styledGenre.style)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview("Loaded") {
    GenreResultsView.preview(repository: PreviewSearchRepository())
}

#Preview("Loading") {
    GenreResultsView.preview(
        repository: PreviewSearchRepository(behavior: .delayedForever)
    )
}

#Preview("Empty") {
    GenreResultsView.preview(
        repository: PreviewSearchRepository(discoverResult: .empty)
    )
}

#Preview("Error") {
    GenreResultsView.preview(
        repository: PreviewSearchRepository(behavior: .alwaysFailing)
    )
}
#endif
