//
//  SearchViewModelTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

@MainActor
struct SearchViewModelTests {

    // MARK: - Genre Loading

    @Test("loadGenres populates genreItems on success")
    func loadGenresSuccess() async {
        let repository = SearchRepositorySpy()
        let viewModel = SearchViewModel(repository: repository)

        #expect(viewModel.genreItems.isEmpty)
        #expect(viewModel.hasLoadedGenres == false)

        await viewModel.loadGenres()

        #expect(repository.fetchGenresCallCount == 1)
        #expect(viewModel.genreItems.count == Genre.mockArray.count)
        #expect(viewModel.hasLoadedGenres == true)
        #expect(viewModel.isLoadingGenres == false)
        #expect(viewModel.genreError == nil)
    }

    @Test("loadGenres is idempotent after first success")
    func loadGenresIdempotent() async {
        let repository = SearchRepositorySpy()
        let viewModel = SearchViewModel(repository: repository)

        await viewModel.loadGenres()
        await viewModel.loadGenres()

        #expect(repository.fetchGenresCallCount == 1)
        #expect(viewModel.hasLoadedGenres == true)
        #expect(viewModel.isLoadingGenres == false)
    }

    @Test("loadGenres maps repository failure into SearchLoadError")
    func loadGenresFailure() async {
        let repository = SearchRepositorySpy(
            genresResult: .failure(TMDBNetworkingError.network)
        )
        let viewModel = SearchViewModel(repository: repository)

        await viewModel.loadGenres()

        #expect(repository.fetchGenresCallCount == 1)
        #expect(viewModel.hasLoadedGenres == false)
        #expect(viewModel.isLoadingGenres == false)
        #expect(viewModel.genreItems.isEmpty)
        #expect((viewModel.genreError as? SearchLoadError) == .network)
    }

    @Test("loadGenres maps decoding error correctly")
    func loadGenresDecodingError() async {
        let repository = SearchRepositorySpy(
            genresResult: .failure(TMDBNetworkingError.decoding)
        )
        let viewModel = SearchViewModel(repository: repository)

        await viewModel.loadGenres()

        #expect((viewModel.genreError as? SearchLoadError) == .decoding)
    }

    @Test("retryLoadGenres resets state and retries")
    func retryLoadGenres() async {
        let repository = SearchRepositorySpy(
            genresResult: .failure(TMDBNetworkingError.network)
        )
        let viewModel = SearchViewModel(repository: repository)

        await viewModel.loadGenres()
        #expect(viewModel.hasLoadedGenres == false)
        #expect(viewModel.genreError != nil)
        #expect(viewModel.showsGenreError == true)

        repository.genresResult = .success(Genre.mockArray)
        await viewModel.retryLoadGenres()

        #expect(repository.fetchGenresCallCount == 2)
        #expect(viewModel.hasLoadedGenres == true)
        #expect(viewModel.genreError == nil)
        #expect(viewModel.showsGenreError == false)
        #expect(!viewModel.genreItems.isEmpty)
    }

    @Test("genreItems transforms genres through GenreGradientMapper")
    func genreItemsMatchMapper() async {
        let genres: [Genre] = [.action, .comedy, .drama]
        let repository = SearchRepositorySpy(genresResult: .success(genres))
        let viewModel = SearchViewModel(repository: repository)

        await viewModel.loadGenres()

        #expect(viewModel.genreItems.count == 3)
        #expect(viewModel.genreItems[0].genre.name == "Action")
        #expect(viewModel.genreItems[1].genre.name == "Comedy")
        #expect(viewModel.genreItems[2].genre.name == "Drama")
    }

    // MARK: - showsGenreError

    @Test("showsGenreError is true when genreError is set and not loading")
    func showsGenreErrorTrue() async {
        let repository = SearchRepositorySpy(
            genresResult: .failure(TMDBNetworkingError.network)
        )
        let viewModel = SearchViewModel(repository: repository)

        await viewModel.loadGenres()

        #expect(viewModel.showsGenreError == true)
    }

    @Test("showsGenreError is false when no error")
    func showsGenreErrorFalseNoError() {
        let viewModel = SearchViewModel(repository: SearchRepositorySpy())
        #expect(viewModel.showsGenreError == false)
    }

    // MARK: - Search State

    @Test("hasSearchQuery returns false for empty and whitespace strings")
    func hasSearchQueryEmpty() {
        let viewModel = SearchViewModel(repository: SearchRepositorySpy())

        viewModel.searchQuery = ""
        #expect(viewModel.hasSearchQuery == false)

        viewModel.searchQuery = "   "
        #expect(viewModel.hasSearchQuery == false)
    }

    @Test("hasSearchQuery returns true for non-empty trimmed strings")
    func hasSearchQueryNonEmpty() {
        let viewModel = SearchViewModel(repository: SearchRepositorySpy())

        viewModel.searchQuery = "batman"
        #expect(viewModel.hasSearchQuery == true)
    }

    // MARK: - Empty State

    @Test("showsEmptyState is false when no query")
    func emptyStateFalseNoQuery() {
        let viewModel = SearchViewModel(repository: SearchRepositorySpy())
        #expect(viewModel.showsEmptyState == false)
    }

    @Test("showsEmptyState is false while searching")
    func emptyStateFalseWhileSearching() {
        let viewModel = SearchViewModel(repository: SearchRepositorySpy())
        viewModel.searchQuery = "batman"
        #expect(viewModel.isSearching == true)
        #expect(viewModel.showsEmptyState == false)
    }

    @Test("showsEmptyState is true when query present, not searching, results empty")
    func emptyStateTrueWhenNoResults() async {
        let repository = SearchRepositorySpy(
            searchResult: .success(MovieResponse(page: 1, results: [], totalPages: 1, totalResults: 0))
        )
        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "xyznonexistent"
        try? await Task.sleep(nanoseconds: 600_000_000)

        #expect(viewModel.isSearching == false)
        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.showsEmptyState == true)
    }

    @Test("showsEmptyState is false when results exist")
    func emptyStateFalseWithResults() async {
        let repository = SearchRepositorySpy()
        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "batman"
        try? await Task.sleep(nanoseconds: 600_000_000)

        #expect(!viewModel.searchResults.isEmpty)
        #expect(viewModel.showsEmptyState == false)
    }

    // MARK: - Clear Search

    @Test("clearSearch resets query and results")
    func clearSearch() {
        let viewModel = SearchViewModel(repository: SearchRepositorySpy())

        viewModel.searchQuery = "test"
        viewModel.clearSearch()

        #expect(viewModel.searchQuery.isEmpty)
        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.isSearching == false)
    }

    // MARK: - Pagination Cap

    @Test("loadNextPage stops at 5-page cap when API has more pages")
    func paginationStopsAtCap() async {
        let repository = SearchRepositorySpy()
        repository.searchHandler = { _, page in
            MovieResponse(page: page, results: [.mock], totalPages: 20, totalResults: 400)
        }
        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "test"
        try? await Task.sleep(nanoseconds: 600_000_000)

        for _ in 2...5 {
            await viewModel.loadNextPage()
        }

        #expect(viewModel.currentPage == 5)
        #expect(viewModel.canLoadMore == false)

        let callsBefore = repository.searchCallCount
        await viewModel.loadNextPage()
        #expect(repository.searchCallCount == callsBefore)
    }

    @Test("loadNextPage stops when API totalPages reached before cap")
    func paginationStopsAtApiTotal() async {
        let repository = SearchRepositorySpy()
        repository.searchHandler = { _, page in
            MovieResponse(page: page, results: [.mock], totalPages: 3, totalResults: 60)
        }
        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "test"
        try? await Task.sleep(nanoseconds: 600_000_000)

        await viewModel.loadNextPage()
        await viewModel.loadNextPage()

        #expect(viewModel.currentPage == 3)
        #expect(viewModel.canLoadMore == false)

        let callsBefore = repository.searchCallCount
        await viewModel.loadNextPage()
        #expect(repository.searchCallCount == callsBefore)
    }

    @Test("loadNextPage stops when API totalPages equals cap")
    func paginationStopsWhenApiEqualsMax() async {
        let repository = SearchRepositorySpy()
        repository.searchHandler = { _, page in
            MovieResponse(page: page, results: [.mock], totalPages: 5, totalResults: 100)
        }
        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "test"
        try? await Task.sleep(nanoseconds: 600_000_000)

        for _ in 2...5 {
            await viewModel.loadNextPage()
        }

        #expect(viewModel.currentPage == 5)
        #expect(viewModel.canLoadMore == false)
    }

    // MARK: - Search Error State

    @Test("performSearch sets searchError on failure")
    func performSearchSetsError() async {
        let repository = SearchRepositorySpy(
            searchResult: .failure(TMDBNetworkingError.network)
        )
        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "batman"
        try? await Task.sleep(nanoseconds: 600_000_000)

        #expect(viewModel.searchError == .network)
        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.isSearching == false)
    }

    @Test("performSearch clears searchError on success")
    func performSearchClearsError() async {
        let repository = SearchRepositorySpy(
            searchResult: .failure(TMDBNetworkingError.network)
        )
        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "batman"
        try? await Task.sleep(nanoseconds: 600_000_000)
        #expect(viewModel.searchError == .network)

        repository.searchResult = .success(.mock)
        viewModel.searchQuery = "batman2"
        try? await Task.sleep(nanoseconds: 600_000_000)

        #expect(viewModel.searchError == nil)
        #expect(!viewModel.searchResults.isEmpty)
    }

    @Test("loadNextPage keeps results on error")
    func loadNextPageKeepsResultsOnError() async {
        let repository = SearchRepositorySpy()
        var callCount = 0
        repository.searchHandler = { _, page in
            callCount += 1
            if callCount == 1 {
                return MovieResponse(page: 1, results: [.mock], totalPages: 5, totalResults: 100)
            }
            throw TMDBNetworkingError.network
        }
        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "test"
        try? await Task.sleep(nanoseconds: 600_000_000)
        #expect(!viewModel.searchResults.isEmpty)

        await viewModel.loadNextPage()

        #expect(viewModel.searchError == nil)
        #expect(!viewModel.searchResults.isEmpty)
    }

    @Test("searchError is cleared when query changes")
    func searchErrorClearedOnQueryChange() async {
        let repository = SearchRepositorySpy(
            searchResult: .failure(TMDBNetworkingError.network)
        )
        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "batman"
        try? await Task.sleep(nanoseconds: 600_000_000)
        #expect(viewModel.searchError == .network)

        viewModel.searchQuery = "bat"
        #expect(viewModel.searchError == nil)
    }

    @Test("showsEmptyState is false when searchError is set")
    func showsEmptyStateFalseWithError() {
        let viewModel = SearchViewModel(repository: SearchRepositorySpy())
        viewModel.searchQuery = "batman"
        viewModel.isSearching = false
        viewModel.searchError = .network

        #expect(viewModel.showsEmptyState == false)
    }

    @Test("retrySearch re-fires current query")
    func retrySearchRefires() async {
        let repository = SearchRepositorySpy(
            searchResult: .failure(TMDBNetworkingError.network)
        )
        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "batman"
        try? await Task.sleep(nanoseconds: 600_000_000)
        #expect(viewModel.searchError == .network)

        repository.searchResult = .success(.mock)
        viewModel.retrySearch()
        try? await Task.sleep(nanoseconds: 200_000_000)

        #expect(viewModel.searchError == nil)
        #expect(!viewModel.searchResults.isEmpty)
        #expect(viewModel.isSearching == false)
    }

    @Test("clearSearch clears searchError")
    func clearSearchClearsError() async {
        let repository = SearchRepositorySpy(
            searchResult: .failure(TMDBNetworkingError.network)
        )
        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "batman"
        try? await Task.sleep(nanoseconds: 600_000_000)
        #expect(viewModel.searchError == .network)

        viewModel.clearSearch()
        #expect(viewModel.searchError == nil)
    }

    // MARK: - Race Conditions

    @Test("stale cancelled search cannot clear loading state for the latest request")
    func staleCancelledSearchDoesNotClearLoadingState() async {
        let repository = SearchRepositorySpy()
        repository.searchHandler = { query, _ in
            switch query {
            case "bat":
                try await Task.sleep(nanoseconds: 3_000_000_000)
                return makeMovieResponse([.mock])
            case "batman":
                try await Task.sleep(nanoseconds: 600_000_000)
                return makeMovieResponse([.mockMario])
            default:
                return .mock
            }
        }

        let viewModel = SearchViewModel(repository: repository)

        viewModel.searchQuery = "bat"
        try? await Task.sleep(nanoseconds: 600_000_000)
        #expect(viewModel.isSearching == true)

        viewModel.searchQuery = "batman"
        try? await Task.sleep(nanoseconds: 550_000_000)

        #expect(repository.searchCallCount == 2)
        #expect(viewModel.isSearching == true)

        try? await Task.sleep(nanoseconds: 700_000_000)

        #expect(viewModel.isSearching == false)
        #expect(viewModel.searchResults.map(\.id) == [Movie.mockMario.id])
    }
}

// MARK: - Test Doubles

private final class SearchRepositorySpy: SearchRepository {
    private(set) var fetchGenresCallCount = 0
    private(set) var searchCallCount = 0
    private(set) var lastSearchQuery: String?

    var genresResult: Result<[Genre], Error>
    var searchResult: Result<MovieResponse, Error>
    var searchHandler: ((String, Int) async throws -> MovieResponse)?

    init(
        genresResult: Result<[Genre], Error> = .success(Genre.mockArray),
        searchResult: Result<MovieResponse, Error> = .success(.mock)
    ) {
        self.genresResult = genresResult
        self.searchResult = searchResult
    }

    func fetchGenres() async throws -> [Genre] {
        fetchGenresCallCount += 1
        return try genresResult.get()
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResponse {
        searchCallCount += 1
        lastSearchQuery = query
        if let searchHandler {
            return try await searchHandler(query, page)
        }
        return try searchResult.get()
    }

    func discoverMovies(genreID: Int, page: Int) async throws -> MovieResponse {
        .mock
    }
}

private func makeMovieResponse(_ movies: [Movie]) -> MovieResponse {
    MovieResponse(
        page: 1,
        results: movies,
        totalPages: 1,
        totalResults: movies.count
    )
}
