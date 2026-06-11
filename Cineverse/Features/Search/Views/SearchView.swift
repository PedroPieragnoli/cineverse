//
//  SearchView.swift
//  Cineverse
//

import SwiftUI

struct SearchView: View {
    // MARK: - Layout Constants

    private enum Layout {
        static let genreExitDuration: TimeInterval = 0.2
        static let resultsEntryDuration: TimeInterval = 0.25
        static let resultsEntryDelay: TimeInterval = 0.05
    }

    // MARK: - Properties

    let viewModel: SearchViewModel
    var hiddenTransitionSourceID: String?
    var onDetailRequested: (DetailRoute) -> Void = { _ in }

    @FocusState private var isSearchBarFocused: Bool

    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            ZStack {
                if viewModel.hasSearchQuery {
                    searchResultsContent
                        .zIndex(1)
                        .transition(.asymmetric(
                            insertion: resultsEntry,
                            removal: resultsExit
                        ))
                } else {
                    genreScrollContent
                        .zIndex(0)
                        .transition(genreTransition)
                }
            }
        }
        .animation(.easeOut(duration: Layout.resultsEntryDuration), value: viewModel.hasSearchQuery)
        .background(DesignSystem.Colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadGenres()
        }
        .onChange(of: viewModel.isSearching) { _, _ in
            announceSearchOutcome()
        }
    }

    // MARK: - Transitions

    private var genreTransition: AnyTransition {
        slideFade(
            verticalOffset: DesignSystem.Spacing.xs,
            animation: .easeOut(duration: Layout.genreExitDuration)
        )
    }

    private var resultsEntry: AnyTransition {
        slideFade(
            verticalOffset: DesignSystem.Spacing.sm,
            animation: .easeOut(duration: Layout.resultsEntryDuration).delay(Layout.resultsEntryDelay)
        )
    }

    private var resultsExit: AnyTransition {
        slideFade(
            verticalOffset: DesignSystem.Spacing.sm,
            animation: .easeOut(duration: Layout.genreExitDuration)
        )
    }

    private func slideFade(verticalOffset: CGFloat, animation: Animation) -> AnyTransition {
        if reduceMotion {
            return .opacity.animation(animation)
        }

        return .opacity
            .combined(with: .offset(y: verticalOffset))
            .animation(animation)
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
                    SkeletonSearchResultsList()
                } else {
                    switch viewModel.searchOutcome {
                    case .error:
                        ErrorStateView(configuration: .searchError) {
                            viewModel.retrySearch()
                        }
                    case .empty:
                        SearchEmptyStateView()
                    case .results:
                        resultRows
                        paginationSpinner
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
            .padding(.top, DesignSystem.Spacing.md)
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
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
                .accessibilityLabel(String(localized: "search.pagination.accessibilityLabel"))
                .accessibilityAddTraits(.updatesFrequently)
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
                    browseByGenreHeader
                    GenreGridView(items: viewModel.genreItems)
                }
            }
            .padding(.top, DesignSystem.Spacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    private var browseByGenreHeader: some View {
        Text(String(localized: "search.browseByGenre.title"))
            .font(DesignSystem.Typography.sectionTitle)
            .foregroundStyle(.white)
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Accessibility

    private func announceSearchOutcome() {
        guard isVoiceOverEnabled, let outcome = viewModel.settledSearchOutcome else { return }

        var announcement = AttributedString(outcome.announcement)
        announcement.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(announcement).post()
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
