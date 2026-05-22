//
//  GenreResultsViewModelTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

@MainActor
struct GenreResultsViewModelTests {

    @Test("Initial load populates results and moves to .loaded")
    func loadInitialSuccess() async {
        let (viewModel, repository) = makeSUT(genre: .action)

        #expect(viewModel.phase == .loading)
        #expect(viewModel.results.isEmpty)

        await viewModel.loadInitial()

        #expect(repository.discoverCallCount == 1)
        #expect(repository.lastGenreID == Genre.action.id)
        #expect(repository.lastPage == 1)
        #expect(viewModel.phase == .loaded)
        #expect(viewModel.results.map(\.id) == MovieResponse.mock.results.map(\.id))
        #expect(viewModel.currentPage == MovieResponse.mock.page)
        #expect(viewModel.totalPages == MovieResponse.mock.totalPages)
    }

    @Test("Initial load with empty response moves to .empty")
    func loadInitialEmpty() async {
        let emptyResponse = MovieResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
        let (viewModel, repository) = makeSUT(genre: .comedy, result: .success(emptyResponse))

        await viewModel.loadInitial()

        #expect(repository.discoverCallCount == 1)
        #expect(viewModel.phase == .empty)
        #expect(viewModel.results.isEmpty)
    }

    @Test("Retry from .error re-runs page 1 and recovers to .loaded")
    func errorThenRetryRecovers() async {
        let (viewModel, repository) = makeSUT(
            genre: .horror,
            result: .failure(TMDBNetworkingError.network)
        )

        await viewModel.loadInitial()

        #expect(repository.discoverCallCount == 1)
        #expect(viewModel.phase == .error(.network))
        #expect(viewModel.results.isEmpty)

        repository.discoverResult = .success(.mock)
        await viewModel.retry()

        #expect(repository.discoverCallCount == 2)
        #expect(repository.lastGenreID == Genre.horror.id)
        #expect(repository.lastPage == 1)
        #expect(viewModel.phase == .loaded)
        #expect(viewModel.results.map(\.id) == MovieResponse.mock.results.map(\.id))
    }

    @Test("Second loadInitial call is a no-op")
    func loadInitialIsIdempotent() async {
        let (viewModel, repository) = makeSUT()

        await viewModel.loadInitial()
        await viewModel.loadInitial()

        #expect(repository.discoverCallCount == 1)
    }

    @Test("Retry from .loaded is a no-op")
    func retryFromNonErrorIsNoOp() async {
        let (viewModel, repository) = makeSUT()

        await viewModel.loadInitial()
        #expect(viewModel.phase == .loaded)

        await viewModel.retry()

        #expect(repository.discoverCallCount == 1)
    }

    @Test("CancellationError keeps phase at .loading without surfacing an error")
    func cancellationDoesNotSurfaceError() async {
        let (viewModel, _) = makeSUT(result: .failure(CancellationError()))

        await viewModel.loadInitial()

        #expect(viewModel.phase == .loading)
        #expect(viewModel.results.isEmpty)
    }

    // MARK: - Pagination

    @Test("loadNextPageIfNeeded fetches the next page and appends results")
    func paginationAppendsNextPage() async {
        let page1 = makeFirstPage()
        let page2 = MovieResponse(page: 2, results: [.mockShazam, .mockAvatar], totalPages: 3, totalResults: 60)
        let (viewModel, repository) = makeSUT(genre: .action, result: .success(page1))

        await viewModel.loadInitial()
        #expect(viewModel.phase == .loaded)
        #expect(viewModel.currentPage == 1)

        repository.discoverResult = .success(page2)
        await viewModel.loadNextPageIfNeeded()

        #expect(repository.discoverCallCount == 2)
        #expect(repository.lastGenreID == Genre.action.id)
        #expect(repository.lastPage == 2)
        #expect(viewModel.phase == .loaded)
        #expect(viewModel.currentPage == 2)
        #expect(viewModel.results.map(\.id) == [Movie.mock, .mockMario, .mockShazam, .mockAvatar].map(\.id))
    }

    @Test("loadNextPageIfNeeded is a no-op on the last page")
    func paginationNoOpOnLastPage() async {
        let onlyPage = MovieResponse(page: 1, results: [.mock, .mockMario], totalPages: 1, totalResults: 2)
        let (viewModel, repository) = makeSUT(result: .success(onlyPage))

        await viewModel.loadInitial()
        #expect(viewModel.currentPage == viewModel.totalPages)

        await viewModel.loadNextPageIfNeeded()

        #expect(repository.discoverCallCount == 1)
        #expect(viewModel.phase == .loaded)
    }

    @Test("Mid-pagination failure keeps loaded results and drops the spinner")
    func paginationFailurePreservesResults() async {
        let page1 = makeFirstPage()
        let (viewModel, repository) = makeSUT(result: .success(page1))

        await viewModel.loadInitial()

        repository.discoverResult = .failure(TMDBNetworkingError.network)
        await viewModel.loadNextPageIfNeeded()

        #expect(repository.discoverCallCount == 2)
        #expect(viewModel.phase == .loaded)
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.results.map(\.id) == [Movie.mock, .mockMario].map(\.id))
    }

    @Test("Cancelled pagination returns to .loaded without surfacing an error")
    func paginationCancellationReturnsToLoaded() async {
        let page1 = makeFirstPage()
        let (viewModel, repository) = makeSUT(result: .success(page1))

        await viewModel.loadInitial()

        repository.discoverResult = .failure(CancellationError())
        await viewModel.loadNextPageIfNeeded()

        #expect(repository.discoverCallCount == 2)
        #expect(viewModel.phase == .loaded)
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.results.map(\.id) == [Movie.mock, .mockMario].map(\.id))
    }

    @Test("loadNextPageIfNeeded is a no-op before the initial load completes")
    func paginationNoOpBeforeInitialLoad() async {
        let (viewModel, repository) = makeSUT()

        await viewModel.loadNextPageIfNeeded()

        #expect(repository.discoverCallCount == 0)
        #expect(viewModel.phase == .loading)
    }

    @Test("loadNextPageIfNeeded is a no-op while a page fetch is already in flight")
    func paginationSerializesConcurrentTriggers() async {
        let page1 = makeFirstPage()
        let repository = SuspendingGenreRepositorySpy(firstPage: page1)
        let viewModel = GenreResultsViewModel(genre: .action, repository: repository)

        await viewModel.loadInitial()
        #expect(viewModel.phase == .loaded)

        let inFlight = Task { await viewModel.loadNextPageIfNeeded() }
        await repository.waitUntilSecondPageEntered()
        #expect(viewModel.phase == .paginating)

        await viewModel.loadNextPageIfNeeded()

        #expect(repository.discoverCallCount == 2)

        repository.releaseSecondPage()
        await inFlight.value
        #expect(viewModel.phase == .loaded)
        #expect(viewModel.currentPage == 2)
        #expect(viewModel.results.map(\.id) == [Movie.mock, .mockMario, .mockShazam].map(\.id))
    }

    // MARK: - Helpers

    private func makeSUT(
        genre: Genre = .action,
        result: Result<MovieResponse, Error> = .success(.mock)
    ) -> (GenreResultsViewModel, GenreRepositorySpy) {
        let repository = GenreRepositorySpy(discoverResult: result)
        let viewModel = GenreResultsViewModel(genre: genre, repository: repository)
        return (viewModel, repository)
    }

    /// Page 1 of a 3-page genre result set, used to drive the pagination tests.
    private func makeFirstPage() -> MovieResponse {
        MovieResponse(page: 1, results: [.mock, .mockMario], totalPages: 3, totalResults: 60)
    }
}

// MARK: - Test Doubles

private final class GenreRepositorySpy: SearchRepository {
    private(set) var discoverCallCount = 0
    private(set) var lastGenreID: Int?
    private(set) var lastPage: Int?

    var discoverResult: Result<MovieResponse, Error>

    init(discoverResult: Result<MovieResponse, Error> = .success(.mock)) {
        self.discoverResult = discoverResult
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResponse {
        .mock
    }

    func fetchGenres() async throws -> [Genre] {
        Genre.mockArray
    }

    func discoverMovies(genreID: Int, page: Int) async throws -> MovieResponse {
        discoverCallCount += 1
        lastGenreID = genreID
        lastPage = page
        return try discoverResult.get()
    }
}

/// Holds the second-page fetch suspended so a test can observe the `.paginating` phase
/// and fire a concurrent trigger against the re-entry guard.
@MainActor
private final class SuspendingGenreRepositorySpy: SearchRepository {
    private(set) var discoverCallCount = 0
    private let firstPage: MovieResponse
    private var didEnterSecondPage = false
    private var enteredContinuation: CheckedContinuation<Void, Never>?
    private var releaseContinuation: CheckedContinuation<Void, Never>?

    init(firstPage: MovieResponse) {
        self.firstPage = firstPage
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResponse {
        .mock
    }

    func fetchGenres() async throws -> [Genre] {
        Genre.mockArray
    }

    func discoverMovies(genreID: Int, page: Int) async throws -> MovieResponse {
        discoverCallCount += 1
        guard page > 1 else { return firstPage }

        didEnterSecondPage = true
        enteredContinuation?.resume()
        enteredContinuation = nil
        await withCheckedContinuation { releaseContinuation = $0 }
        return MovieResponse(page: page, results: [.mockShazam], totalPages: firstPage.totalPages, totalResults: 60)
    }

    func waitUntilSecondPageEntered() async {
        guard !didEnterSecondPage else { return }
        await withCheckedContinuation { enteredContinuation = $0 }
    }

    func releaseSecondPage() {
        releaseContinuation?.resume()
        releaseContinuation = nil
    }
}
