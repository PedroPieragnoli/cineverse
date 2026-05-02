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

        repository.genresResult = .success(Genre.mockArray)
        await viewModel.retryLoadGenres()

        #expect(repository.fetchGenresCallCount == 2)
        #expect(viewModel.hasLoadedGenres == true)
        #expect(viewModel.genreError == nil)
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

    @Test("clearSearch resets query and results")
    func clearSearch() {
        let viewModel = SearchViewModel(repository: SearchRepositorySpy())

        viewModel.searchQuery = "test"
        viewModel.clearSearch()

        #expect(viewModel.searchQuery.isEmpty)
        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.isSearching == false)
    }

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
}

private func makeMovieResponse(_ movies: [Movie]) -> MovieResponse {
    MovieResponse(
        page: 1,
        results: movies,
        totalPages: 1,
        totalResults: movies.count
    )
}
