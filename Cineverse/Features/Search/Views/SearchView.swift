//
//  SearchView.swift
//  Cineverse
//

import SwiftUI

struct SearchView: View {
    // MARK: - Layout Constants

    private enum Layout {
        static let skeletonRowCount = 4
    }

    // MARK: - Properties

    let viewModel: SearchViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            if viewModel.hasSearchQuery {
                searchResultsContent
            } else {
                genreScrollContent
            }
        }
        .background(DesignSystem.Colors.background.ignoresSafeArea())
        .task {
            await viewModel.loadGenres()
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        SearchBarView(
            text: Bindable(viewModel).searchQuery
        ) {
            viewModel.clearSearch()
        }
        .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
        .padding(.top, DesignSystem.Spacing.sm)
    }

    private var searchResultsContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if viewModel.isSearching {
                    skeletonRows
                } else {
                    resultRows
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
        ForEach(Array(viewModel.searchResultItems.enumerated()), id: \.element.id) { index, item in
            SearchResultRowView(
                item: item,
                showDivider: index < viewModel.searchResultItems.count - 1
            )
        }
    }

    private var genreScrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                sectionTitle
                GenreGridView(items: viewModel.genreItems)
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
#endif
