//
//  DefaultSearchRepositoryTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct DefaultSearchRepositoryTests {
    @Test("Repository returns movie response from remote data source")
    func returnsMovieResponse() async throws {
        let expectedResponse = makeMovieResponse([makeMovie(id: 1)])
        let repository = DefaultSearchRepository(
            remoteDataSource: SearchRemoteDataSourceStub(
                searchResult: .success(expectedResponse),
                genres: .success(GenreResponse(genres: []))
            )
        )

        let response = try await repository.searchMovies(query: "Test", page: 1)

        #expect(response.results.map(\.id) == [1])
        #expect(response.totalPages == 1)
    }

    @Test("Repository unwraps genre response into genre array")
    func unwrapsGenreResponse() async throws {
        let genres = [Genre(id: 28, name: "Action"), Genre(id: 12, name: "Adventure")]
        let repository = DefaultSearchRepository(
            remoteDataSource: SearchRemoteDataSourceStub(
                searchResult: .success(makeMovieResponse([])),
                genres: .success(GenreResponse(genres: genres))
            )
        )

        let result = try await repository.fetchGenres()

        #expect(result.count == 2)
        #expect(result.map(\.name) == ["Action", "Adventure"])
    }

    @Test("Search propagates remote data source errors")
    func searchPropagatesErrors() async {
        let repository = DefaultSearchRepository(
            remoteDataSource: SearchRemoteDataSourceStub(
                searchResult: .failure(TMDBNetworkingError.network),
                genres: .success(GenreResponse(genres: []))
            )
        )

        await #expect(throws: TMDBNetworkingError.network) {
            _ = try await repository.searchMovies(query: "Test", page: 1)
        }
    }

    @Test("Fetch genres propagates remote data source errors")
    func fetchGenresPropagatesErrors() async {
        let repository = DefaultSearchRepository(
            remoteDataSource: SearchRemoteDataSourceStub(
                searchResult: .success(makeMovieResponse([])),
                genres: .failure(TMDBNetworkingError.decoding)
            )
        )

        await #expect(throws: TMDBNetworkingError.decoding) {
            _ = try await repository.fetchGenres()
        }
    }

    @Test("Search forwards query and page to remote data source")
    func forwardsQueryAndPage() async throws {
        let spy = SearchRemoteDataSourceSpy(
            searchResult: makeMovieResponse([]),
            genres: GenreResponse(genres: [])
        )
        let repository = DefaultSearchRepository(remoteDataSource: spy)

        _ = try await repository.searchMovies(query: "Matrix", page: 3)

        #expect(spy.capturedQuery == "Matrix")
        #expect(spy.capturedPage == 3)
    }

    @Test("Repository returns discover response from remote data source")
    func returnsDiscoverResponse() async throws {
        let expectedResponse = makeMovieResponse([makeMovie(id: 42)])
        let repository = DefaultSearchRepository(
            remoteDataSource: SearchRemoteDataSourceStub(
                searchResult: .success(makeMovieResponse([])),
                genres: .success(GenreResponse(genres: [])),
                discoverResult: .success(expectedResponse)
            )
        )

        let response = try await repository.discoverMovies(genreID: 28, page: 1)

        #expect(response.results.map(\.id) == [42])
    }

    @Test("Discover forwards genre ID and page to remote data source")
    func discoverForwardsGenreIDAndPage() async throws {
        let spy = SearchRemoteDataSourceSpy(
            searchResult: makeMovieResponse([]),
            genres: GenreResponse(genres: [])
        )
        let repository = DefaultSearchRepository(remoteDataSource: spy)

        _ = try await repository.discoverMovies(genreID: 28, page: 4)

        #expect(spy.capturedDiscoverGenreID == 28)
        #expect(spy.capturedDiscoverPage == 4)
    }
}

private struct SearchRemoteDataSourceStub: SearchRemoteDataSource {
    let searchResult: Result<MovieResponse, Error>
    let genres: Result<GenreResponse, Error>
    var discoverResult: Result<MovieResponse, Error> = .success(
        MovieResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
    )

    func searchMovies(query: String, page: Int) async throws -> MovieResponse {
        try searchResult.get()
    }

    func fetchGenres() async throws -> GenreResponse {
        try genres.get()
    }

    func discoverMovies(genreID: Int, page: Int) async throws -> MovieResponse {
        try discoverResult.get()
    }
}

private final class SearchRemoteDataSourceSpy: SearchRemoteDataSource {
    let searchResult: MovieResponse
    let genres: GenreResponse
    private(set) var capturedQuery: String?
    private(set) var capturedPage: Int?
    private(set) var capturedDiscoverGenreID: Int?
    private(set) var capturedDiscoverPage: Int?

    init(searchResult: MovieResponse, genres: GenreResponse) {
        self.searchResult = searchResult
        self.genres = genres
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResponse {
        capturedQuery = query
        capturedPage = page
        return searchResult
    }

    func fetchGenres() async throws -> GenreResponse {
        genres
    }

    func discoverMovies(genreID: Int, page: Int) async throws -> MovieResponse {
        capturedDiscoverGenreID = genreID
        capturedDiscoverPage = page
        return searchResult
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

private func makeMovie(id: Int) -> Movie {
    Movie(
        id: id,
        adult: false,
        backdropPath: "/hero.jpg",
        genreIds: [28],
        originalLanguage: "en",
        originalTitle: "Original \(id)",
        overview: "Overview \(id)",
        popularity: 90.0,
        posterPath: "/poster-\(id).jpg",
        releaseDate: "2025-01-01",
        title: "Movie \(id)",
        video: false,
        voteAverage: 7.0,
        voteCount: 80
    )
}
