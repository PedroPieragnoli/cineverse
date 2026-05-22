//
//  SearchView.swift
//  Cineverse
//

import SwiftUI

struct SearchView: View {
    // MARK: - Layout Constants

    private enum Layout {
        static let skeletonRowCount = 4
        static let genreExitDuration: TimeInterval = 0.2
        static let resultsEntryDuration: TimeInterval = 0.25
        static let resultsEntryDelay: TimeInterval = 0.05
    }

    // MARK: - Transitions

    private static let genreExit: AnyTransition = .opacity
        .combined(with: .offset(y: DesignSystem.Spacing.xs))
        .animation(.easeOut(duration: Layout.genreExitDuration))

    private static let genreEntry: AnyTransition = .opacity
        .combined(with: .offset(y: DesignSystem.Spacing.xs))
        .animation(.easeOut(duration: Layout.genreExitDuration))

    private static let resultsEntry: AnyTransition = .opacity
        .combined(with: .offset(y: DesignSystem.Spacing.sm))
        .animation(.easeOut(duration: Layout.resultsEntryDuration)
            .delay(Layout.resultsEntryDelay))

    private static let resultsExit: AnyTransition = .opacity
        .combined(with: .offset(y: DesignSystem.Spacing.sm))
        .animation(.easeOut(duration: Layout.genreExitDuration))

    // MARK: - Properties

    let viewModel: SearchViewModel
    var hiddenTransitionSourceID: String?
    var onDetailRequested: (DetailRoute) -> Void = { _ in }

    @FocusState private var isSearchBarFocused: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            ZStack {
                if viewModel.hasSearchQuery {
                    searchResultsContent
                        .zIndex(1)
                        .transition(.asymmetric(
                            insertion: Self.resultsEntry,
                            removal: Self.resultsExit
                        ))
                } else {
                    genreScrollContent
                        .zIndex(0)
                        .transition(.asymmetric(
                            insertion: Self.genreEntry,
                            removal: Self.genreExit
                        ))
                }
            }
        }
        .animation(.easeOut(duration: Layout.resultsEntryDuration), value: viewModel.hasSearchQuery)
        .background(DesignSystem.Colors.background.ignoresSafeArea())
        .task {
            await viewModel.loadGenres()
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        SearchBarView(
            text: Bindable(viewModel).searchQuery,
            isFocused: $isSearchBarFocused
        ) {
            viewModel.clearSearch()
        }
        .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    private var searchResultsContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if viewModel.isSearching {
                    skeletonRows
                } else if viewModel.searchError != nil {
                    ErrorStateView(configuration: .searchError) {
                        viewModel.retrySearch()
                    }
                } else if viewModel.showsEmptyState {
                    SearchEmptyStateView()
                } else {
                    resultRows
                    paginationSpinner
                }
            }
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
            .padding(.top, DesignSystem.Spacing.md)
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
    }

    private var skeletonRows: some View {
        ForEach(0..<Layout.skeletonRowCount, id: \.self) { index in
            SkeletonSearchResultRowView(showDivider: index < Layout.skeletonRowCount - 1)
        }
    }

    private var resultRows: some View {
        ForEach(
            Array(viewModel.searchResultItems.enumerated()),
            id: \.element.id
        ) { index, item in
            SearchResultRowView(
                item: item,
                showDivider: index < viewModel.searchResultItems.count - 1,
                isSourceHidden: hiddenTransitionSourceID == DetailRoute.transitionSourceID(for: item.movie.id),
                onTap: handleResultTapped
            )
            .onAppear {
                if index == viewModel.searchResultItems.count - 3 {
                    Task { await viewModel.loadNextPage() }
                }
            }
        }
    }

    @ViewBuilder
    private var paginationSpinner: some View {
        if viewModel.isPaginating {
            ProgressView()
                .tint(DesignSystem.Colors.primary)
                .frame(height: DesignSystem.Spacing.xxl)
                .frame(maxWidth: .infinity)
                .padding(.top, DesignSystem.Spacing.lg)
        }
    }

    private var genreScrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                if viewModel.showsGenreError {
                    ErrorStateView(configuration: .genreError) {
                        Task { await viewModel.retryLoadGenres() }
                    }
                } else {
                    sectionTitle
                    GenreGridView(items: viewModel.genreItems)
                }
            }
            .padding(.top, DesignSystem.Spacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    private var sectionTitle: some View {
        Text(String(localized: "search.browseByGenre.title"))
            .font(DesignSystem.Typography.sectionTitle)
            .foregroundStyle(.white)
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }

    // MARK: - Actions

    private func handleResultTapped(_ movie: Movie, frame: CGRect) {
        isSearchBarFocused = false
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
#Preview("Search - Idle") {
    SearchView(viewModel: SearchViewModel(repository: PreviewSearchRepository()))
        .preferredColorScheme(.dark)
}

#Preview("Search - Loading") {
    let viewModel = SearchViewModel(repository: PreviewSearchRepository())
    viewModel.searchQuery = "test"
    viewModel.isSearching = true
    return SearchView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Search - Results") {
    let viewModel = SearchViewModel(repository: PreviewSearchRepository())
    viewModel.searchQuery = "mario"
    return SearchView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Search - Empty") {
    let emptyResponse = MovieResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
    let viewModel = SearchViewModel(
        repository: PreviewSearchRepository(searchResult: emptyResponse)
    )
    viewModel.searchQuery = "xyznonexistent"
    return SearchView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Search - Error") {
    let viewModel = SearchViewModel(repository: PreviewSearchRepository())
    viewModel.searchQuery = "batman"
    viewModel.isSearching = false
    viewModel.searchError = .network
    return SearchView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Search - Genre Error") {
    let viewModel = SearchViewModel(repository: PreviewSearchRepository())
    viewModel.genreError = SearchLoadError.network
    return SearchView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#endif
