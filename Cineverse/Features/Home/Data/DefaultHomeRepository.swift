//
//  DefaultHomeRepository.swift
//  Cineverse
//

import Foundation

struct DefaultHomeRepository: HomeRepository {
    private let remoteDataSource: HomeRemoteDataSource
    private let continueWatchingStore: ContinueWatchingStore

    init(
        remoteDataSource: HomeRemoteDataSource,
        continueWatchingStore: ContinueWatchingStore
    ) {
        self.remoteDataSource = remoteDataSource
        self.continueWatchingStore = continueWatchingStore
    }

    func fetchHomePayload() async throws -> HomePayload {
        async let trendingResult = captureResult(remoteDataSource.fetchTrending)
        async let upcomingResult = captureResult(remoteDataSource.fetchUpcoming)
        async let genresResult = captureResult(remoteDataSource.fetchGenres)
        async let continueWatchingResult = captureResult(continueWatchingStore.loadItems)

        let (trending, upcoming, genres, continueWatching) = await (
            trendingResult,
            upcomingResult,
            genresResult,
            continueWatchingResult
        )

        let payload = buildPayload(
            trending: trending,
            upcoming: upcoming,
            genres: genres,
            continueWatching: continueWatching
        )

        try validateCriticalContentOrThrow(
            payload: payload,
            from: [trending.error, upcoming.error]
        )
        return payload
    }

    private func makeFeaturedMovie(from movies: [Movie], genres: [Genre]) -> FeaturedMovie? {
        guard let selectedMovie = movies.first(where: { $0.backdropPath != nil }) ?? movies.first else {
            return nil
        }

        return FeaturedMovie(movie: selectedMovie, allGenres: genres)
    }

    private func buildPayload(
        trending: Result<MovieResponse, Error>,
        upcoming: Result<MovieResponse, Error>,
        genres: Result<GenreResponse, Error>,
        continueWatching: Result<[ContinueWatchingItem], Error>
    ) -> HomePayload {
        let allTrendingMovies = trending.value?.results ?? []
        let newReleases = upcoming.value?.results ?? []
        let allGenres = genres.value?.genres ?? []
        let continueWatchingItems = continueWatching.value ?? []
        let featuredMovie = makeFeaturedMovie(from: allTrendingMovies, genres: allGenres)
        let trendingMovies = allTrendingMovies.filter { $0.id != featuredMovie?.id }

        return HomePayload(
            featuredMovie: featuredMovie,
            trendingMovies: trendingMovies,
            newReleases: newReleases,
            continueWatching: continueWatchingItems
        )
    }

    private func validateCriticalContentOrThrow(
        payload: HomePayload,
        from prioritizedErrors: [Error?]
    ) throws {
        let hasCriticalContent = !payload.trendingMovies.isEmpty
            || !payload.newReleases.isEmpty
            || !payload.continueWatching.isEmpty

        if hasCriticalContent {
            return
        }

        if let prioritizedError = HomeLoadError.prioritized(from: prioritizedErrors) {
            throw prioritizedError
        }

        throw HomeLoadError.emptyCriticalContent
    }

    private func captureResult<T>(_ operation: () async throws -> T) async -> Result<T, Error> {
        do {
            return .success(try await operation())
        } catch {
            return .failure(error)
        }
    }
}

extension DefaultHomeRepository {
    static func live(
        environment: TMDBEnvironment = .live(),
        session: URLSession = .shared,
        continueWatchingStore: ContinueWatchingStore = SeededContinueWatchingStore()
    ) -> DefaultHomeRepository {
        let httpClient = URLSessionHTTPClient(
            baseURL: environment.baseURL,
            session: session
        )
        let requestBuilder = TMDBRequestBuilder(environment: environment)
        let remoteDataSource = TMDBHomeRemoteDataSource(
            httpClient: httpClient,
            requestBuilder: requestBuilder
        )

        return DefaultHomeRepository(
            remoteDataSource: remoteDataSource,
            continueWatchingStore: continueWatchingStore
        )
    }
}

private extension Result where Failure == Error {
    var value: Success? {
        guard case let .success(value) = self else {
            return nil
        }
        return value
    }

    var error: Error? {
        guard case let .failure(error) = self else {
            return nil
        }
        return error
    }
}
