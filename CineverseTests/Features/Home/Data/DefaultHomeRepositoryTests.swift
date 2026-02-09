//
//  DefaultHomeRepositoryTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct DefaultHomeRepositoryTests {
    @Test("Repository maps successful responses into home payload")
    func mapsSuccessfulResponses() async throws {
        let trendingMovie = makeMovie(id: 1, backdropPath: "/hero.jpg", genreIds: [28], releaseDate: "2024-05-10")
        let upcomingMovie = makeMovie(id: 2, backdropPath: "/upcoming.jpg", genreIds: [12], releaseDate: "2024-06-12")
        let continueItem = ContinueWatchingItem(
            movie: makeMovie(id: 3),
            progress: 0.3,
            remainingSeconds: 1_200
        )

        let repository = DefaultHomeRepository(
            remoteDataSource: HomeRemoteDataSourceStub(
                trending: .success(makeMovieResponse([trendingMovie])),
                upcoming: .success(makeMovieResponse([upcomingMovie])),
                genres: .success(
                    GenreResponse(genres: [
                        Genre(id: 28, name: "Action"),
                        Genre(id: 12, name: "Adventure")
                    ])
                )
            ),
            continueWatchingStore: ContinueWatchingStoreStub(
                result: .success([continueItem])
            )
        )

        let payload = try await repository.fetchHomePayload()

        #expect(payload.trendingMovies.map(\.id) == [1])
        #expect(payload.newReleases.map(\.id) == [2])
        #expect(payload.continueWatching.map(\.id) == [3])
        #expect(payload.featuredMovie?.id == 1)
        #expect(payload.featuredMovie?.metadataText.contains("Action") == true)
    }

    @Test("Repository keeps healthy sections when one remote list fails")
    func keepsHealthySectionsOnPartialFailure() async throws {
        let repository = DefaultHomeRepository(
            remoteDataSource: HomeRemoteDataSourceStub(
                trending: .failure(TMDBNetworkingError.network),
                upcoming: .success(makeMovieResponse([makeMovie(id: 11)])),
                genres: .success(GenreResponse(genres: []))
            ),
            continueWatchingStore: ContinueWatchingStoreStub(result: .success([]))
        )

        let payload = try await repository.fetchHomePayload()

        #expect(payload.trendingMovies.isEmpty)
        #expect(payload.newReleases.map(\.id) == [11])
        #expect(payload.featuredMovie == nil)
    }

    @Test("Featured movie falls back to first trending when no backdrops exist")
    func featuredMovieFallbackWithoutBackdrop() async throws {
        let repository = DefaultHomeRepository(
            remoteDataSource: HomeRemoteDataSourceStub(
                trending: .success(
                    makeMovieResponse([
                        makeMovie(id: 21, backdropPath: nil),
                        makeMovie(id: 22, backdropPath: nil)
                    ])
                ),
                upcoming: .success(makeMovieResponse([])),
                genres: .success(GenreResponse(genres: []))
            ),
            continueWatchingStore: ContinueWatchingStoreStub(result: .success([]))
        )

        let payload = try await repository.fetchHomePayload()

        #expect(payload.featuredMovie?.id == 21)
    }

    @Test("Genre failure does not block featured movie mapping")
    func genreFailureDoesNotBlockPayload() async throws {
        let repository = DefaultHomeRepository(
            remoteDataSource: HomeRemoteDataSourceStub(
                trending: .success(makeMovieResponse([makeMovie(id: 31, genreIds: [28])])),
                upcoming: .success(makeMovieResponse([])),
                genres: .failure(TMDBNetworkingError.network)
            ),
            continueWatchingStore: ContinueWatchingStoreStub(result: .success([]))
        )

        let payload = try await repository.fetchHomePayload()

        #expect(payload.trendingMovies.map(\.id) == [31])
        #expect(payload.featuredMovie?.id == 31)
    }

    @Test("Continue-watching store failure does not block remote movie sections")
    func continueWatchingFailureDoesNotBlockRemoteContent() async throws {
        let repository = DefaultHomeRepository(
            remoteDataSource: HomeRemoteDataSourceStub(
                trending: .success(makeMovieResponse([makeMovie(id: 41)])),
                upcoming: .failure(TMDBNetworkingError.network),
                genres: .success(GenreResponse(genres: []))
            ),
            continueWatchingStore: ContinueWatchingStoreStub(
                result: .failure(TMDBNetworkingError.network)
            )
        )

        let payload = try await repository.fetchHomePayload()

        #expect(payload.trendingMovies.map(\.id) == [41])
        #expect(payload.newReleases.isEmpty)
        #expect(payload.continueWatching.isEmpty)
    }

    @Test("Full failure prioritizes missing token error")
    func fullFailurePrioritizesMissingToken() async {
        let repository = DefaultHomeRepository(
            remoteDataSource: HomeRemoteDataSourceStub(
                trending: .failure(TMDBNetworkingError.network),
                upcoming: .failure(TMDBNetworkingError.missingTMDBToken),
                genres: .success(GenreResponse(genres: []))
            ),
            continueWatchingStore: ContinueWatchingStoreStub(result: .success([]))
        )

        await #expect(throws: HomeLoadError.missingTMDBToken) {
            _ = try await repository.fetchHomePayload()
        }
    }

    @Test("Full failure prioritizes decoding over network")
    func fullFailurePrioritizesDecodingOverNetwork() async {
        let repository = DefaultHomeRepository(
            remoteDataSource: HomeRemoteDataSourceStub(
                trending: .failure(TMDBNetworkingError.network),
                upcoming: .failure(TMDBNetworkingError.decoding),
                genres: .success(GenreResponse(genres: []))
            ),
            continueWatchingStore: ContinueWatchingStoreStub(result: .success([]))
        )

        await #expect(throws: HomeLoadError.decoding) {
            _ = try await repository.fetchHomePayload()
        }
    }

    @Test("Full failure maps to network when no higher-priority error exists")
    func fullFailureMapsToNetwork() async {
        let repository = DefaultHomeRepository(
            remoteDataSource: HomeRemoteDataSourceStub(
                trending: .failure(TMDBNetworkingError.network),
                upcoming: .failure(TMDBNetworkingError.network),
                genres: .success(GenreResponse(genres: []))
            ),
            continueWatchingStore: ContinueWatchingStoreStub(result: .success([]))
        )

        await #expect(throws: HomeLoadError.network) {
            _ = try await repository.fetchHomePayload()
        }
    }

    @Test("Empty successful payload throws empty critical content")
    func emptySuccessfulPayloadThrowsEmptyCriticalContent() async {
        let repository = DefaultHomeRepository(
            remoteDataSource: HomeRemoteDataSourceStub(
                trending: .success(makeMovieResponse([])),
                upcoming: .success(makeMovieResponse([])),
                genres: .success(GenreResponse(genres: []))
            ),
            continueWatchingStore: ContinueWatchingStoreStub(result: .success([]))
        )

        await #expect(throws: HomeLoadError.emptyCriticalContent) {
            _ = try await repository.fetchHomePayload()
        }
    }
}

private struct HomeRemoteDataSourceStub: HomeRemoteDataSource {
    let trending: Result<MovieResponse, Error>
    let upcoming: Result<MovieResponse, Error>
    let genres: Result<GenreResponse, Error>

    func fetchTrending() async throws -> MovieResponse {
        try trending.get()
    }

    func fetchUpcoming() async throws -> MovieResponse {
        try upcoming.get()
    }

    func fetchGenres() async throws -> GenreResponse {
        try genres.get()
    }
}

private struct ContinueWatchingStoreStub: ContinueWatchingStore {
    let result: Result<[ContinueWatchingItem], Error>

    func loadItems() async throws -> [ContinueWatchingItem] {
        try result.get()
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
        popularity: 90.0,
        posterPath: "/poster-\(id).jpg",
        releaseDate: releaseDate,
        title: "Movie \(id)",
        video: false,
        voteAverage: 7.0,
        voteCount: 80
    )
}
