//
//  TMDBHomeRemoteDataSourceTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct TMDBHomeRemoteDataSourceTests {
    @Test("Trending request uses expected path, method, auth and locale")
    func trendingRequestUsesPathMethodAuthAndLocale() async throws {
        let (dataSource, client) = makeSUT(language: "pt", region: "BR")
        client.responseDataByPath["/trending/movie/week"] = encode(
            MovieResponse(
                page: 1,
                results: [makeMovie(id: 101)],
                totalPages: 1,
                totalResults: 1
            )
        )

        let response = try await dataSource.fetchTrending()
        let request = try #require(client.capturedRequests.first)

        #expect(response.results.first?.id == 101)
        #expect(request.method == .get)
        #expect(request.path == "/trending/movie/week")
        #expect(request.headers["Authorization"] == "Bearer token-123")
        #expect(request.headers["Accept"] == "application/json")
        #expect(request.queryItems.contains { $0.name == "language" && $0.value == "pt" })
        #expect(request.queryItems.contains { $0.name == "region" && $0.value == "BR" })
        #expect(!request.queryItems.contains { $0.name == "api_key" })
    }

    @Test("Upcoming request uses path, method, auth and locale")
    func upcomingRequestUsesPathMethodAuthAndLocale() async throws {
        let (dataSource, client) = makeSUT()
        client.responseDataByPath["/movie/upcoming"] = encode(
            MovieResponse(
                page: 1,
                results: [makeMovie(id: 202)],
                totalPages: 1,
                totalResults: 1
            )
        )

        let response = try await dataSource.fetchUpcoming()
        let request = try #require(client.capturedRequests.first)

        #expect(response.results.first?.id == 202)
        #expect(request.method == .get)
        #expect(request.path == "/movie/upcoming")
        #expect(request.headers["Authorization"] == "Bearer token-123")
        #expect(request.headers["Accept"] == "application/json")
        #expect(request.queryItems.contains { $0.name == "language" && $0.value == "en" })
        #expect(request.queryItems.contains { $0.name == "region" && $0.value == "US" })
        #expect(!request.queryItems.contains { $0.name == "api_key" })
    }

    @Test("Genres request uses path, method, auth and locale")
    func genresRequestUsesPathMethodAuthAndLocale() async throws {
        let (dataSource, client) = makeSUT()
        client.responseDataByPath["/genre/movie/list"] = encode(
            GenreResponse(
                genres: [
                    Genre(id: 28, name: "Action"),
                    Genre(id: 12, name: "Adventure")
                ]
            )
        )

        let response = try await dataSource.fetchGenres()
        let request = try #require(client.capturedRequests.first)

        #expect(response.genres.count == 2)
        #expect(request.method == .get)
        #expect(request.path == "/genre/movie/list")
        #expect(request.headers["Authorization"] == "Bearer token-123")
        #expect(request.headers["Accept"] == "application/json")
        #expect(request.queryItems.contains { $0.name == "language" && $0.value == "en" })
        #expect(request.queryItems.contains { $0.name == "region" && $0.value == "US" })
        #expect(!request.queryItems.contains { $0.name == "api_key" })
    }

    @Test("Trending surfaces transport errors")
    func trendingSurfacesTransportError() async {
        let (dataSource, client) = makeSUT()
        client.errorByPath["/trending/movie/week"] = TMDBNetworkingError.network

        await #expect(throws: TMDBNetworkingError.network) {
            _ = try await dataSource.fetchTrending()
        }
    }

    @Test("Trending throws missing token when access token is empty")
    func trendingThrowsMissingTokenWhenTokenIsEmpty() async {
        let (dataSource, _) = makeSUT(token: "")

        await #expect(throws: TMDBNetworkingError.missingTMDBToken) {
            _ = try await dataSource.fetchTrending()
        }
    }

    private func makeSUT(
        language: String = "en",
        region: String = "US",
        token: String = "token-123"
    ) -> (TMDBHomeRemoteDataSource, HTTPClientSpy) {
        let environment = TMDBEnvironment(
            baseURL: URL(string: "https://api.themoviedb.org/3")!,
            readAccessToken: token,
            language: language,
            region: region
        )
        let client = HTTPClientSpy()
        let dataSource = TMDBHomeRemoteDataSource(
            httpClient: client,
            requestBuilder: TMDBRequestBuilder(environment: environment)
        )
        return (dataSource, client)
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
        popularity: 120.5,
        posterPath: "/poster-\(id).jpg",
        releaseDate: releaseDate,
        title: "Movie \(id)",
        video: false,
        voteAverage: 7.4,
        voteCount: 123
    )
}
