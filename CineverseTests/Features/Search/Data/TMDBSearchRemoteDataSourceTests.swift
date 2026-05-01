//
//  TMDBSearchRemoteDataSourceTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

@Suite(.serialized)
struct TMDBSearchRemoteDataSourceTests {
    @Test("Search request uses correct path, query params, and includes include_adult=false")
    func searchBuildsExpectedRequest() async throws {
        let client = HTTPClientSpy()
        client.responseDataByPath["/search/movie"] = encode(
            MovieResponse(
                page: 1,
                results: [makeMovie(id: 101)],
                totalPages: 5,
                totalResults: 100
            )
        )

        let environment = TMDBEnvironment(
            baseURL: URL(string: "https://api.themoviedb.org/3")!,
            readAccessToken: "token-123",
            language: "pt",
            region: "BR"
        )
        let dataSource = TMDBSearchRemoteDataSource(
            httpClient: client,
            requestBuilder: TMDBRequestBuilder(environment: environment)
        )

        let response = try await dataSource.searchMovies(query: "Fight Club", page: 1)
        let request = try #require(client.capturedRequests.first)

        #expect(response.results.first?.id == 101)
        #expect(request.method == .get)
        #expect(request.path == "/search/movie")
        #expect(request.headers["Authorization"] == "Bearer token-123")
        #expect(request.headers["Accept"] == "application/json")
        #expect(request.queryItems.contains { $0.name == "query" && $0.value == "Fight Club" })
        #expect(request.queryItems.contains { $0.name == "page" && $0.value == "1" })
        #expect(request.queryItems.contains { $0.name == "include_adult" && $0.value == "false" })
        #expect(request.queryItems.contains { $0.name == "language" && $0.value == "pt" })
        #expect(request.queryItems.contains { $0.name == "region" && $0.value == "BR" })
    }

    @Test("Genres request targets /genre/movie/list")
    func fetchGenresUsesGenresEndpoint() async throws {
        let client = HTTPClientSpy()
        client.responseDataByPath["/genre/movie/list"] = encode(
            GenreResponse(
                genres: [
                    Genre(id: 28, name: "Action"),
                    Genre(id: 12, name: "Adventure")
                ]
            )
        )

        let environment = TMDBEnvironment(
            baseURL: URL(string: "https://api.themoviedb.org/3")!,
            readAccessToken: "token-123",
            language: "en",
            region: "US"
        )
        let dataSource = TMDBSearchRemoteDataSource(
            httpClient: client,
            requestBuilder: TMDBRequestBuilder(environment: environment)
        )

        let response = try await dataSource.fetchGenres()
        let request = try #require(client.capturedRequests.first)

        #expect(response.genres.count == 2)
        #expect(request.method == .get)
        #expect(request.path == "/genre/movie/list")
    }

    @Test("Search request encodes page number as string")
    func searchEncodesPageNumber() async throws {
        let client = HTTPClientSpy()
        client.responseDataByPath["/search/movie"] = encode(
            MovieResponse(
                page: 3,
                results: [makeMovie(id: 201)],
                totalPages: 10,
                totalResults: 200
            )
        )

        let environment = TMDBEnvironment(
            baseURL: URL(string: "https://api.themoviedb.org/3")!,
            readAccessToken: "token-123",
            language: "en",
            region: "US"
        )
        let dataSource = TMDBSearchRemoteDataSource(
            httpClient: client,
            requestBuilder: TMDBRequestBuilder(environment: environment)
        )

        let response = try await dataSource.searchMovies(query: "Matrix", page: 3)
        let request = try #require(client.capturedRequests.first)

        #expect(response.page == 3)
        #expect(request.queryItems.contains { $0.name == "page" && $0.value == "3" })
    }
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
        popularity: 120.5,
        posterPath: "/poster-\(id).jpg",
        releaseDate: "2025-01-01",
        title: "Movie \(id)",
        video: false,
        voteAverage: 7.4,
        voteCount: 123
    )
}
