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
    }

    // MARK: - Genre State

    var genreItems: [GenreGradientItem] = []
    var isLoadingGenres = false
    var genreError: Error?
    private(set) var hasLoadedGenres = false

    // MARK: - Search State

    var searchQuery = "" {
        didSet { onSearchQueryChanged() }
    }
    var isSearching = false
    private(set) var searchResults: [Movie] = []
    private var searchTask: Task<Void, Never>?
    private var activeSearchID = UUID()

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

    var hasSearchQuery: Bool {
        !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func clearSearch() {
        searchTask?.cancel()
        searchTask = nil
        activeSearchID = UUID()
        searchQuery = ""
        searchResults = []
        isSearching = false
    }

    private func onSearchQueryChanged() {
        searchTask?.cancel()

        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            activeSearchID = UUID()
            searchResults = []
            isSearching = false
            searchTask = nil
            return
        }

        let searchID = UUID()
        activeSearchID = searchID

        searchTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await Task.sleep(nanoseconds: Constants.debounceNanoseconds)
            } catch {
                return
            }

            guard !Task.isCancelled, self.activeSearchID == searchID else { return }

            self.isSearching = true

            do {
                let response = try await self.repository.searchMovies(
                    query: trimmed,
                    page: 1
                )
                guard !Task.isCancelled, self.activeSearchID == searchID else { return }
                self.searchResults = response.results
            } catch is CancellationError {
                // Swallow cancellation
            } catch {
                // Error state for search results is delivery 5
            }

            guard self.activeSearchID == searchID else { return }
            self.isSearching = false
            self.searchTask = nil
        }
    }
}
