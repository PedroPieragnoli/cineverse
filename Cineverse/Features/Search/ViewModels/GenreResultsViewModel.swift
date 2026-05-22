//
//  GenreResultsViewModel.swift
//  Cineverse
//

import Foundation

@MainActor
@Observable
final class GenreResultsViewModel {
    enum Phase: Equatable {
        case loading
        case loaded
        case empty
        case error(SearchLoadError)
    }

    let genre: Genre
    private let repository: SearchRepository

    private(set) var phase: Phase = .loading
    private(set) var results: [Movie] = []
    private(set) var currentPage = 0
    private(set) var totalPages = 0
    private var hasStartedInitialLoad = false

    init(genre: Genre, repository: SearchRepository) {
        self.genre = genre
        self.repository = repository
    }

    func loadInitial() async {
        guard !hasStartedInitialLoad else { return }
        hasStartedInitialLoad = true
        await fetchFirstPage()
    }

    func retry() async {
        guard case .error = phase else { return }
        phase = .loading
        results = []
        currentPage = 0
        totalPages = 0
        await fetchFirstPage()
    }

    private func fetchFirstPage() async {
        do {
            let response = try await repository.discoverMovies(genreID: genre.id, page: 1)
            apply(response)
        } catch is CancellationError {
            // Swallow cancellation
        } catch {
            phase = .error(SearchLoadError.map(error))
        }
    }

    private func apply(_ response: MovieResponse) {
        results = response.results
        currentPage = response.page
        totalPages = response.totalPages
        phase = response.results.isEmpty ? .empty : .loaded
    }
}
