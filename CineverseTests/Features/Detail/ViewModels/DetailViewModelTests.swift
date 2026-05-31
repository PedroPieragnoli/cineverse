//
//  DetailViewModelTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

@MainActor
struct DetailViewModelTests {

    // MARK: - Loading

    @Test("loadInitialData populates state on success")
    func loadInitialDataSuccess() async {
        let payload = MovieDetailPayload(
            detail: MovieDetailResponse(
                id: 550,
                title: "Fight Club",
                overview: "Overview",
                posterPath: "/poster.jpg",
                releaseDate: "1999-10-15",
                voteAverage: 8.4,
                runtime: 139,
                genres: [Genre(id: 18, name: "Drama")]
            ),
            cast: [
                MovieCastMember(id: 1, name: "Brad Pitt", character: "Tyler", profilePath: "/profile.jpg")
            ]
        )

        let (viewModel, repository, _) = makeViewModel(
            id: 550,
            result: .success(payload),
            favoriteIDs: [550]
        )

        await viewModel.loadInitialData()

        #expect(repository.fetchCallCount == 1)
        #expect(repository.receivedMovieIDs == [550])
        #expect(viewModel.hasLoadedInitialData)
        #expect(!viewModel.isLoading)
        #expect(viewModel.error == nil)
        #expect(viewModel.title == "Fight Club")
        #expect(viewModel.cast.first?.name == "Brad Pitt")
        #expect(viewModel.cast.first?.character == "Tyler")
        #expect(viewModel.genreNames == ["Drama"])
        #expect(viewModel.isInMyList)
    }

    @Test("loadInitialData stores failure state")
    func loadInitialDataFailure() async throws {
        let (viewModel, repository, _) = makeViewModel(
            id: 551,
            result: .failure(TMDBNetworkingError.network)
        )

        await viewModel.loadInitialData()

        #expect(repository.fetchCallCount == 1)
        #expect(!viewModel.hasLoadedInitialData)

        let error = try #require(viewModel.error as? TMDBNetworkingError)
        #expect(error == .network)
    }

    @Test("isLoading reflects the in-flight fetch and resets after completion")
    func isLoadingReflectsInFlightFetch() async {
        let entered = AsyncStream<Void>.makeStream()
        let release = AsyncStream<Void>.makeStream()

        let repository = DetailRepositorySpy(result: .success(makePayload(id: 1)))
        repository.onFetch = {
            entered.continuation.yield(())
            for await _ in release.stream { break }
        }
        let viewModel = DetailViewModel(
            movie: makeMovie(id: 1),
            repository: repository,
            favoritesStore: FavoriteMoviesStoreSpy(initialFavoriteIDs: [])
        )

        #expect(!viewModel.isLoading)

        let task = Task { await viewModel.loadInitialData() }

        var enteredIterator = entered.stream.makeAsyncIterator()
        _ = await enteredIterator.next()

        #expect(viewModel.isLoading)
        #expect(!viewModel.hasLoadedInitialData)

        release.continuation.yield(())
        release.continuation.finish()
        _ = await task.value

        #expect(!viewModel.isLoading)
        #expect(viewModel.hasLoadedInitialData)
    }

    @Test("loadInitialData retries after failure and reaches success")
    func loadInitialDataRetryAfterFailure() async {
        let payload = makePayload(id: 1)
        let repository = DetailRepositorySpy(results: [
            .failure(TMDBNetworkingError.network),
            .success(payload)
        ])
        let viewModel = DetailViewModel(
            movie: makeMovie(id: 1),
            repository: repository,
            favoritesStore: FavoriteMoviesStoreSpy(initialFavoriteIDs: [])
        )

        await viewModel.loadInitialData()
        #expect(viewModel.error != nil)
        #expect(!viewModel.hasLoadedInitialData)

        await viewModel.loadInitialData()

        #expect(viewModel.error == nil)
        #expect(viewModel.hasLoadedInitialData)
        #expect(repository.fetchCallCount == 2)
        #expect(repository.receivedMovieIDs == [1, 1])
    }

    @Test("loadInitialData is a no-op after success")
    func loadInitialDataDoesNotRefetch() async {
        let (viewModel, repository, _) = makeViewModel(id: 42)

        await viewModel.loadInitialData()
        await viewModel.loadInitialData()

        #expect(repository.fetchCallCount == 1)
    }

    @Test("loadInitialData ignores CancellationError without recording error")
    func loadInitialDataSwallowsCancellation() async {
        let (viewModel, _, _) = makeViewModel(
            id: 1,
            result: .failure(CancellationError())
        )

        await viewModel.loadInitialData()

        #expect(viewModel.error == nil)
        #expect(!viewModel.hasLoadedInitialData)
    }

    @Test("View model falls back to base movie when detail is not yet loaded")
    func fallsBackToBaseMovieBeforeLoad() {
        let (viewModel, _, _) = makeViewModel(id: 7)

        #expect(viewModel.title == "Movie 7")
        #expect(viewModel.overview == "Movie overview 7")
        #expect(viewModel.genreNames.isEmpty)
        #expect(viewModel.cast.isEmpty)
        #expect(viewModel.posterURL == Movie.previewPosterURL(forID: 7))
        #expect(viewModel.ratingPercentage == 70)
        #expect(viewModel.yearRuntimeText == "2024")
    }

    // MARK: - Derived Text

    @Test("genreNames is capped at the first two genres")
    func genreNamesIsCappedAtTwo() async {
        let payload = makePayload(id: 1, genres: [
            Genre(id: 1, name: "Action"),
            Genre(id: 2, name: "Adventure"),
            Genre(id: 3, name: "Comedy")
        ])
        let (viewModel, _, _) = makeViewModel(id: 1, result: .success(payload))

        await viewModel.loadInitialData()

        #expect(viewModel.genreNames == ["Action", "Adventure"])
    }

    @Test("yearRuntimeText shows only the year when runtime is zero")
    func yearRuntimeTextOmitsRuntimeWhenZero() async {
        let payload = makePayload(id: 1, runtime: 0)
        let (viewModel, _, _) = makeViewModel(id: 1, result: .success(payload))

        await viewModel.loadInitialData()

        #expect(viewModel.yearRuntimeText == "2024")
    }

    @Test("yearRuntimeText joins year and runtime with bullet separator")
    func yearRuntimeTextJoinsYearAndRuntime() async {
        let payload = makePayload(id: 1, runtime: 124)
        let (viewModel, _, _) = makeViewModel(id: 1, result: .success(payload))

        await viewModel.loadInitialData()

        #expect(viewModel.yearRuntimeText.hasPrefix("2024 • "))
    }

    // MARK: - My List

    @Test("toggleMyList updates persisted state")
    func toggleMyListUpdatesState() {
        let (viewModel, _, favoritesStore) = makeViewModel(id: 777)

        #expect(!viewModel.isInMyList)

        viewModel.toggleMyList()
        #expect(viewModel.isInMyList)
        #expect(favoritesStore.contains(777))

        viewModel.toggleMyList()
        #expect(!viewModel.isInMyList)
        #expect(!favoritesStore.contains(777))
    }

    @Test("toggleMyList removes a movie when it starts in My List")
    func toggleMyListRemovesWhenAlreadyInMyList() {
        let (viewModel, _, favoritesStore) = makeViewModel(id: 42, favoriteIDs: [42])

        #expect(viewModel.isInMyList)

        viewModel.toggleMyList()

        #expect(!viewModel.isInMyList)
        #expect(!favoritesStore.contains(42))
    }

    // MARK: - Overview Expansion

    @Test("toggleOverviewExpanded toggles state")
    func toggleOverviewExpanded() {
        let (viewModel, _, _) = makeViewModel(id: 888)

        #expect(!viewModel.isOverviewExpanded)

        viewModel.toggleOverviewExpanded()
        #expect(viewModel.isOverviewExpanded)

        viewModel.toggleOverviewExpanded()
        #expect(!viewModel.isOverviewExpanded)
    }

    // MARK: - Entrance Animation

    @Test("startEntranceAnimation enables all sections")
    func startEntranceAnimationEnablesSections() async {
        let (viewModel, _, _) = makeViewModel(id: 999)

        await viewModel.startEntranceAnimation(reduceMotion: false)

        #expect(viewModel.showsMetadataSection)
        #expect(viewModel.showsPlayButton)
        #expect(viewModel.showsSecondaryContent)
    }

    @Test("startEntranceAnimation with reduce motion skips staged delays")
    func startEntranceAnimationReduceMotion() async {
        let (viewModel, _, _) = makeViewModel(id: 1000)

        await viewModel.startEntranceAnimation(reduceMotion: true)

        #expect(viewModel.showsMetadataSection)
        #expect(viewModel.showsPlayButton)
        #expect(viewModel.showsSecondaryContent)
    }

    @Test("startEntranceAnimation only runs once")
    func startEntranceAnimationIsIdempotent() async {
        let (viewModel, _, _) = makeViewModel(id: 1002)

        await viewModel.startEntranceAnimation(reduceMotion: true)
        viewModel.toggleOverviewExpanded()
        await viewModel.startEntranceAnimation(reduceMotion: false)

        #expect(viewModel.hasStartedEntranceAnimation)
        #expect(viewModel.isOverviewExpanded)
    }
}

// MARK: - Test Helpers

@MainActor
private func makeViewModel(
    id: Int,
    result: Result<MovieDetailPayload, Error>? = nil,
    favoriteIDs: Set<Int> = []
) -> (viewModel: DetailViewModel, repository: DetailRepositorySpy, favoritesStore: FavoriteMoviesStoreSpy) {
    let repository = DetailRepositorySpy(result: result ?? .success(makePayload(id: id)))
    let favoritesStore = FavoriteMoviesStoreSpy(initialFavoriteIDs: favoriteIDs)
    let viewModel = DetailViewModel(
        movie: makeMovie(id: id),
        repository: repository,
        favoritesStore: favoritesStore
    )
    return (viewModel, repository, favoritesStore)
}

private final class DetailRepositorySpy: DetailRepository, @unchecked Sendable {
    private(set) var receivedMovieIDs: [Int] = []
    private var results: [Result<MovieDetailPayload, Error>]
    var onFetch: (@Sendable () async -> Void)?

    var fetchCallCount: Int { receivedMovieIDs.count }

    init(result: Result<MovieDetailPayload, Error>) {
        self.results = [result]
    }

    init(results: [Result<MovieDetailPayload, Error>]) {
        self.results = results
    }

    func fetchDetail(movieID: Int) async throws -> MovieDetailPayload {
        receivedMovieIDs.append(movieID)
        await onFetch?()
        if results.count > 1 {
            return try results.removeFirst().get()
        }
        return try results[0].get()
    }
}

private final class FavoriteMoviesStoreSpy: FavoriteMoviesStore, @unchecked Sendable {
    private var favoriteIDs: Set<Int>

    init(initialFavoriteIDs: Set<Int>) {
        self.favoriteIDs = initialFavoriteIDs
    }

    func contains(_ movieID: Int) -> Bool {
        favoriteIDs.contains(movieID)
    }

    @discardableResult
    func toggle(_ movieID: Int) -> Bool {
        if favoriteIDs.contains(movieID) {
            favoriteIDs.remove(movieID)
        } else {
            favoriteIDs.insert(movieID)
        }

        return favoriteIDs.contains(movieID)
    }
}

private func makePayload(
    id: Int,
    runtime: Int? = 124,
    genres: [Genre] = [Genre(id: 18, name: "Drama")]
) -> MovieDetailPayload {
    MovieDetailPayload(
        detail: MovieDetailResponse(
            id: id,
            title: "Movie \(id)",
            overview: "Overview \(id)",
            posterPath: "/poster-\(id).jpg",
            releaseDate: "2024-01-01",
            voteAverage: 7.6,
            runtime: runtime,
            genres: genres
        ),
        cast: [
            MovieCastMember(id: 1, name: "Actor", character: "Character", profilePath: "/actor.jpg")
        ]
    )
}

private func makeMovie(id: Int) -> Movie {
    Movie(
        id: id,
        adult: false,
        backdropPath: "/backdrop-\(id).jpg",
        genreIds: [18],
        originalLanguage: "en",
        originalTitle: "Original \(id)",
        overview: "Movie overview \(id)",
        popularity: 10,
        posterPath: "/poster-\(id).jpg",
        releaseDate: "2024-01-01",
        title: "Movie \(id)",
        video: false,
        voteAverage: 7.0,
        voteCount: 100
    )
}

private extension Movie {
    static func previewPosterURL(forID id: Int) -> URL? {
        TMDBConfiguration.posterURL(for: "/poster-\(id).jpg", size: .large)
    }
}
