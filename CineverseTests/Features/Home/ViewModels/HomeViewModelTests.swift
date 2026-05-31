//
//  HomeViewModelTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

@MainActor
struct HomeViewModelTests {
    @Test("loadInitialData populates published state on success")
    func loadInitialDataSuccess() async {
        let featuredMovie = makeMovie(id: 1, backdropPath: "/hero.jpg")
        let trendingMovie = makeMovie(id: 2)
        let newReleaseMovie = makeMovie(id: 3)
        let continueWatchingItem = ContinueWatchingItem(
            movie: makeMovie(id: 4),
            progress: 0.5,
            remainingSeconds: 1_200
        )
        let payload = HomePayload(
            featuredMovie: FeaturedMovie(movie: featuredMovie, allGenres: []),
            trendingMovies: [trendingMovie],
            newReleases: [newReleaseMovie],
            continueWatching: [continueWatchingItem]
        )
        let repository = HomeRepositorySpy(result: .success(payload))
        let viewModel = HomeViewModel(repository: repository)

        #expect(viewModel.isLoading == false)
        #expect(viewModel.hasLoadedInitialData == false)

        await viewModel.loadInitialData()

        #expect(repository.fetchCallCount == 1)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.hasLoadedInitialData == true)
        #expect(viewModel.error == nil)
        #expect(viewModel.featuredMovie?.id == featuredMovie.id)
        #expect(viewModel.trendingMovies.map(\.id) == [trendingMovie.id])
        #expect(viewModel.newReleases.map(\.id) == [newReleaseMovie.id])
        #expect(viewModel.continueWatching.map(\.id) == [continueWatchingItem.id])
    }

    @Test("loadInitialData is idempotent after first success")
    func loadInitialDataIsIdempotent() async {
        let payload = HomePayload(
            featuredMovie: FeaturedMovie(movie: makeMovie(id: 10), allGenres: []),
            trendingMovies: [makeMovie(id: 11)],
            newReleases: [],
            continueWatching: []
        )
        let repository = HomeRepositorySpy(result: .success(payload))
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.loadInitialData()
        await viewModel.loadInitialData()

        #expect(repository.fetchCallCount == 1)
        #expect(viewModel.hasLoadedInitialData == true)
        #expect(viewModel.isLoading == false)
    }

    @Test("loadInitialData maps repository failures into HomeLoadError")
    func loadInitialDataFailureMapsError() async {
        let repository = HomeRepositorySpy(result: .failure(TMDBNetworkingError.decoding))
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.loadInitialData()

        #expect(repository.fetchCallCount == 1)
        #expect(viewModel.hasLoadedInitialData == false)
        #expect(viewModel.isLoading == false)
        #expect((viewModel.error as? HomeLoadError) == .decoding)
    }

    @Test("loadInitialData keeps partial payload content without hard error")
    func loadInitialDataKeepsPartialPayload() async {
        let newReleaseMovie = makeMovie(id: 21)
        let payload = HomePayload(
            featuredMovie: nil,
            trendingMovies: [],
            newReleases: [newReleaseMovie],
            continueWatching: []
        )
        let repository = HomeRepositorySpy(result: .success(payload))
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.loadInitialData()

        #expect(viewModel.hasLoadedInitialData == true)
        #expect(viewModel.error == nil)
        #expect(viewModel.trendingMovies.isEmpty)
        #expect(viewModel.newReleases.map(\.id) == [newReleaseMovie.id])
        #expect(viewModel.sections.count == 1)
    }

    // MARK: - My List

    @Test("loadInitialData seeds the featured My List state from the store")
    func loadInitialDataSeedsFeaturedMyListState() async {
        let (viewModel, _, _) = makeViewModel(featuredID: 55, favoriteIDs: [55])

        #expect(viewModel.isFeaturedMovieInMyList == false)

        await viewModel.loadInitialData()

        #expect(viewModel.isFeaturedMovieInMyList)
    }

    @Test("didTapMyList adds the featured movie to the store")
    func didTapMyListAddsFeaturedMovie() async {
        let (viewModel, store, _) = await makeLoadedViewModel(featuredID: 60)

        viewModel.didTapMyList()

        #expect(viewModel.isFeaturedMovieInMyList)
        #expect(store.toggledIDs == [60])
        #expect(store.contains(60))
    }

    @Test("didTapMyList removes the featured movie when it is already in My List")
    func didTapMyListRemovesWhenAlreadyInMyList() async {
        let (viewModel, store, _) = await makeLoadedViewModel(
            featuredID: 61,
            favoriteIDs: [61]
        )

        #expect(viewModel.isFeaturedMovieInMyList)

        viewModel.didTapMyList()

        #expect(viewModel.isFeaturedMovieInMyList == false)
        #expect(store.toggledIDs == [61])
        #expect(store.contains(61) == false)
    }

    @Test("didTapMyList does nothing when there is no featured movie")
    func didTapMyListWithoutFeaturedMovieDoesNothing() async {
        let (viewModel, store, _) = await makeLoadedViewModel(featuredID: nil)

        viewModel.didTapMyList()

        #expect(viewModel.isFeaturedMovieInMyList == false)
        #expect(store.toggledIDs.isEmpty)
    }

    @Test("refreshMyListState re-reads the store after an external toggle")
    func refreshMyListStateRereadsStore() async {
        let (viewModel, store, _) = await makeLoadedViewModel(featuredID: 62)

        store.addForArrange(62)
        #expect(viewModel.isFeaturedMovieInMyList == false)

        viewModel.refreshMyListState()

        #expect(viewModel.isFeaturedMovieInMyList)
        #expect(store.toggledIDs.isEmpty)
    }

    @Test("refreshMyListState clears the state without consulting the store when there is no featured movie")
    func refreshMyListStateClearsWithoutFeaturedMovie() async {
        let (viewModel, store, _) = await makeLoadedViewModel(
            featuredID: nil,
            favoriteIDs: [70]
        )
        store.resetQueryLog()

        viewModel.refreshMyListState()

        #expect(viewModel.isFeaturedMovieInMyList == false)
        #expect(store.containsQueries.isEmpty)
    }
}

@MainActor
private final class HomeRepositorySpy: HomeRepository {
    private(set) var fetchCallCount = 0
    private let result: Result<HomePayload, Error>

    init(result: Result<HomePayload, Error>) {
        self.result = result
    }

    func fetchHomePayload() async throws -> HomePayload {
        fetchCallCount += 1
        return try result.get()
    }
}

private func makeMovie(
    id: Int,
    backdropPath: String? = "/hero.jpg",
    genreIds: [Int] = [28],
    releaseDate: String = "2025-01-01"
) -> Movie {
    Movie(
        id: id,
        adult: false,
        backdropPath: backdropPath,
        genreIds: genreIds,
        originalLanguage: "en",
        originalTitle: "Original \(id)",
        overview: "Overview \(id)",
        popularity: 99.0,
        posterPath: "/poster-\(id).jpg",
        releaseDate: releaseDate,
        title: "Movie \(id)",
        video: false,
        voteAverage: 7.0,
        voteCount: 90
    )
}

private final class FavoriteMoviesStoreSpy: FavoriteMoviesStore, @unchecked Sendable {
    private(set) var toggledIDs: [Int] = []
    private(set) var containsQueries: [Int] = []
    private var favoriteIDs: Set<Int>

    init(initialFavoriteIDs: Set<Int> = []) {
        self.favoriteIDs = initialFavoriteIDs
    }

    func contains(_ movieID: Int) -> Bool {
        containsQueries.append(movieID)
        return favoriteIDs.contains(movieID)
    }

    @discardableResult
    func toggle(_ movieID: Int) -> Bool {
        toggledIDs.append(movieID)

        if favoriteIDs.contains(movieID) {
            favoriteIDs.remove(movieID)
        } else {
            favoriteIDs.insert(movieID)
        }

        return favoriteIDs.contains(movieID)
    }

    /// Simulates a change made outside the view model under test, without
    /// polluting `toggledIDs` — that log records only calls the view model made.
    func addForArrange(_ movieID: Int) {
        favoriteIDs.insert(movieID)
    }

    func resetQueryLog() {
        containsQueries.removeAll()
    }
}

@MainActor
private func makeViewModel(
    featuredID: Int?,
    favoriteIDs: Set<Int> = []
) -> (viewModel: HomeViewModel, store: FavoriteMoviesStoreSpy, featured: FeaturedMovie?) {
    let featured = featuredID.map { FeaturedMovie(movie: makeMovie(id: $0), allGenres: []) }
    let payload = HomePayload(
        featuredMovie: featured,
        trendingMovies: [],
        newReleases: [],
        continueWatching: []
    )
    let store = FavoriteMoviesStoreSpy(initialFavoriteIDs: favoriteIDs)
    let viewModel = HomeViewModel(
        repository: HomeRepositorySpy(result: .success(payload)),
        favoritesStore: store
    )

    return (viewModel, store, featured)
}

@MainActor
private func makeLoadedViewModel(
    featuredID: Int?,
    favoriteIDs: Set<Int> = []
) async -> (viewModel: HomeViewModel, store: FavoriteMoviesStoreSpy, featured: FeaturedMovie?) {
    let made = makeViewModel(featuredID: featuredID, favoriteIDs: favoriteIDs)
    await made.viewModel.loadInitialData()

    return made
}
