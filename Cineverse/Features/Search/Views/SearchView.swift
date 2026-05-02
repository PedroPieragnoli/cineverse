//
//  SearchView.swift
//  Cineverse
//

import SwiftUI

struct SearchView: View {
    let viewModel: SearchViewModel

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            genreScrollContent
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
#endif
