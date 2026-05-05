//
//  SearchViewModel.swift
//  Cineverse
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class SearchViewModel {
    private let repository: SearchRepository

    private enum Constants {
        static let debounceNanoseconds: UInt64 = 500_000_000
        static let maxPages = 5
    }

    // MARK: - Genre State

    var genreItems: [GenreGradientItem] = []
    var isLoadingGenres = false
    var genreError: Error?
    private(set) var hasLoadedGenres = false

    // MARK: - Search State

    var searchQuery = "" {
        didSet {
            guard searchQuery != oldValue else { return }
            onSearchQueryChanged()
        }
    }
    var isSearching = false
    private(set) var searchResults: [Movie] = []
    private var searchTask: Task<Void, Never>?
    private var activeSearchID = UUID()

    // MARK: - Pagination State

    private(set) var currentPage = 0
    private(set) var totalPages = 1
    private(set) var isPaginating = false

    var canLoadMore: Bool {
        !isPaginating && !isSearching && currentPage < totalPages
            && currentPage < Constants.maxPages && hasSearchQuery
    }

    init(repository: SearchRepository = DefaultSearchRepository.live()) {
        self.repository = repository
    }

    // MARK: - Genre Loading

    func loadGenres() async {
        guard !isLoadingGenres, !hasLoadedGenres else { return }

        isLoadingGenres = true
        genreError = nil
        defer { isLoadingGenres = false }

        do {
            let genres = try await repository.fetchGenres()
            genreItems = GenreGradientMapper.map(genres)
            hasLoadedGenres = true
        } catch is CancellationError {
            hasLoadedGenres = false
        } catch {
            genreError = SearchLoadError.map(error)
            hasLoadedGenres = false
        }
    }

    func retryLoadGenres() async {
        hasLoadedGenres = false
        genreError = nil
        await loadGenres()
    }

    // MARK: - Search

    var searchResultItems: [SearchResultRowItem] {
        let allGenres = genreItems.map(\.genre)
        return searchResults.map { SearchResultRowItem(movie: $0, allGenres: allGenres) }
    }

    var hasSearchQuery: Bool {
        !trimmedQuery.isEmpty
    }

    var showsEmptyState: Bool {
        !isSearching && hasSearchQuery && searchResults.isEmpty
    }

    private var trimmedQuery: String {
        searchQuery.trimmingCharacters(in: .whitespaces)
    }

    func clearSearch() {
        searchTask?.cancel()
        searchTask = nil
        activeSearchID = UUID()
        searchQuery = ""
        searchResults = []
        isSearching = false
        currentPage = 0
        totalPages = 1
        isPaginating = false
    }

    func loadNextPage() async {
        guard canLoadMore else { return }

        let searchID = activeSearchID
        let nextPage = currentPage + 1
        let query = trimmedQuery

        isPaginating = true
        defer { isPaginating = false }

        do {
            let response = try await repository.searchMovies(query: query, page: nextPage)
            guard activeSearchID == searchID else { return }
            applyResponse(response, replace: false)
        } catch is CancellationError {
            // Swallow cancellation
        } catch {
            // Error handling is delivery 5E
        }
    }

    private func applyResponse(_ response: MovieResponse, replace: Bool) {
        if replace {
            searchResults = response.results
        } else {
            searchResults.append(contentsOf: response.results)
        }
        currentPage = response.page
        totalPages = response.totalPages
    }

    private func onSearchQueryChanged() {
        searchTask?.cancel()
        isPaginating = false

        guard !trimmedQuery.isEmpty else {
            activeSearchID = UUID()
            searchResults = []
            isSearching = false
            searchTask = nil
            return
        }

        let searchID = UUID()
        activeSearchID = searchID
        isSearching = true
        currentPage = 0
        totalPages = 1

        searchTask = Task { await performSearch(id: searchID) }
    }

    private func performSearch(id: UUID) async {
        do {
            try await Task.sleep(nanoseconds: Constants.debounceNanoseconds)
        } catch { return }

        guard !Task.isCancelled, activeSearchID == id else { return }

        do {
            let response = try await repository.searchMovies(query: trimmedQuery, page: 1)
            guard !Task.isCancelled, activeSearchID == id else { return }
            applyResponse(response, replace: true)
        } catch is CancellationError {
            // Swallow cancellation
        } catch {
            // Error state for search results is delivery 5
        }

        guard activeSearchID == id else { return }
        isSearching = false
        searchTask = nil
    }
}
