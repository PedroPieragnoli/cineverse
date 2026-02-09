//
//  TMDBHomeRemoteDataSourceTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

@Suite(.serialized)
struct TMDBHomeRemoteDataSourceTests {
    @Test("Trending request uses expected path, method, auth and locale")
    func fetchTrendingBuildsExpectedRequest() async throws {
        let client = HTTPClientSpy()
        client.responseDataByPath["/trending/movie/week"] = encode(
            MovieResponse(
                page: 1,
                results: [makeMovie(id: 101)],
                totalPages: 1,
                totalResults: 1
            )
        )

        let environment = TMDBEnvironment(
            baseURL: URL(string: "https://api.themoviedb.org/3")!,
            readAccessToken: "token-123",
            language: "pt",
            region: "BR"
        )
        let dataSource = TMDBHomeRemoteDataSource(
            httpClient: client,
            requestBuilder: TMDBRequestBuilder(environment: environment)
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

    @Test("Upcoming request targets the /movie/upcoming endpoint")
    func fetchUpcomingUsesUpcomingEndpoint() async throws {
        let client = HTTPClientSpy()
        client.responseDataByPath["/movie/upcoming"] = encode(
            MovieResponse(
                page: 1,
                results: [makeMovie(id: 202)],
                totalPages: 1,
                totalResults: 1
            )
        )

        let environment = TMDBEnvironment(
            baseURL: URL(string: "https://api.themoviedb.org/3")!,
            readAccessToken: "token-123",
            language: "en",
            region: "US"
        )
        let dataSource = TMDBHomeRemoteDataSource(
            httpClient: client,
            requestBuilder: TMDBRequestBuilder(environment: environment)
        )

        let response = try await dataSource.fetchUpcoming()
        let request = try #require(client.capturedRequests.first)

        #expect(response.results.first?.id == 202)
        #expect(request.method == .get)
        #expect(request.path == "/movie/upcoming")
    }

    @Test("Genres request targets the /genre/movie/list endpoint")
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
        let dataSource = TMDBHomeRemoteDataSource(
            httpClient: client,
            requestBuilder: TMDBRequestBuilder(environment: environment)
        )

        let response = try await dataSource.fetchGenres()
        let request = try #require(client.capturedRequests.first)

        #expect(response.genres.count == 2)
        #expect(request.method == .get)
        #expect(request.path == "/genre/movie/list")
    }
}

private final class HTTPClientSpy: HTTPClient {
    struct CapturedRequest {
        let method: HTTPMethod
        let path: String
        let queryItems: [URLQueryItem]
        let headers: [String: String]
    }

    var capturedRequests: [CapturedRequest] = []
    var responseDataByPath: [String: Data] = [:]
    var errorByPath: [String: Error] = [:]

    func send<Response: Decodable>(_ request: APIRequest<Response>) async throws -> Response {
        capturedRequests.append(
            CapturedRequest(
                method: request.method,
                path: request.path,
                queryItems: request.queryItems,
                headers: request.headers
            )
        )

        if let error = errorByPath[request.path] {
            throw error
        }

        let data = try #require(
            responseDataByPath[request.path],
            "Expected stub response for path \(request.path)"
        )

        return try request.decoder.decode(Response.self, from: data)
    }
}

private func encode<T: Encodable>(_ value: T) -> Data {
    let encoder = JSONEncoder()
    return (try? encoder.encode(value)) ?? Data()
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
