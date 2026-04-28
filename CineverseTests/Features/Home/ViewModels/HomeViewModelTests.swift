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
